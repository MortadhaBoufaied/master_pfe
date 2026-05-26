import os
import logging
import torch
import json
import hashlib
from datasets import load_dataset, DatasetDict
from transformers import (
    AutoTokenizer,
    AutoModelForCausalLM,
    Trainer,
    TrainingArguments,
    DataCollatorForLanguageModeling
)
from peft import (
    LoraConfig,
    get_peft_model,
)
from huggingface_hub import login

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

REPO_ID = "tiiuae/falcon-rw-1b"
BASE_MODEL_REVISION = os.getenv("HF_BASE_MODEL_REVISION", "main")
DATASET_REVISION = os.getenv("HF_DATASET_REVISION", "main")
TRAINED_MODEL_DIR = "apps/chat/training_models/models/fine_tuned_falcon"
BASE_MODEL_DIR = "apps/chat/training_models/models/falcon-rw-1b-base"  # Local base model
JSON_PATH = "apps/chat/training_models/data/markdowns-01.json"
HF_TOKEN = os.getenv("HF_TOKEN", "")

# Verification marker
VERIFICATION_MARKER = {
    "finetuned": True,
    "dataset": "ISET_SFAX_QA",
    "version": "1.2"
}

def download_and_save_base_model():
    """Download and save base model locally"""
    if not os.path.exists(BASE_MODEL_DIR):
        os.makedirs(BASE_MODEL_DIR, exist_ok=True)
        logger.info("🔽 Downloading base model...")
        model = AutoModelForCausalLM.from_pretrained(
            REPO_ID,
            revision=BASE_MODEL_REVISION,
            device_map="auto",
            torch_dtype=torch.float16,
        )
        tokenizer = AutoTokenizer.from_pretrained(REPO_ID, revision=BASE_MODEL_REVISION)
        
        model.save_pretrained(BASE_MODEL_DIR)
        tokenizer.save_pretrained(BASE_MODEL_DIR)
        logger.info(f"✅ Base model saved to {BASE_MODEL_DIR}")
    else:
        logger.info("✅ Base model already exists")

def train_model():
    login(token=HF_TOKEN)
    os.makedirs(TRAINED_MODEL_DIR, exist_ok=True)
    
    # 1. Download and save base model
    download_and_save_base_model()
    
    # 2. Load base model from local directory
    logger.info("🔄 Loading base model from local directory...")
    model = AutoModelForCausalLM.from_pretrained(  # nosec B615
        BASE_MODEL_DIR,
        local_files_only=True,
        device_map="auto",
        torch_dtype=torch.float16,
    )
    tokenizer = AutoTokenizer.from_pretrained(BASE_MODEL_DIR, local_files_only=True)  # nosec B615
    
    model.config.use_cache = False
    tokenizer.pad_token = tokenizer.eos_token

    # 3. Apply LoRA
    peft_config = LoraConfig(
        r=8,
        lora_alpha=32,
        target_modules=["query_key_value", "dense"],
        lora_dropout=0.05,
        bias="none",
        task_type="CAUSAL_LM",
    )
    model = get_peft_model(model, peft_config)
    logger.info("✅ Model loaded with PEFT")

    # 4. Load dataset
    raw_dataset = load_dataset("json", data_files=JSON_PATH, revision=DATASET_REVISION)
    dataset = raw_dataset['train'].train_test_split(test_size=0.1, seed=42)
    ds = DatasetDict({"train": dataset["train"], "validation": dataset["test"]})

    def tokenize_fn(examples):
        return tokenizer(
            examples["input"],
            truncation=True,
            max_length=128,
            padding="max_length",
            return_tensors="pt"
        )

    tokenized_ds = ds.map(
        tokenize_fn,
        batched=True,
        remove_columns=["input", "output"]
    )
    tokenized_ds.set_format(type="torch", columns=["input_ids", "attention_mask"])
    logger.info("✅ Dataset tokenized")

    # 5. Training setup
    training_args = TrainingArguments(
        output_dir=TRAINED_MODEL_DIR,
        per_device_train_batch_size=8,
        per_device_eval_batch_size=8,
        gradient_accumulation_steps=2,
        num_train_epochs=15,
        evaluation_strategy="epoch",
        save_strategy="epoch",
        save_total_limit=2,
        learning_rate=1e-4,
        lr_scheduler_type="linear",
        warmup_steps=100,
        weight_decay=0.01,
        load_best_model_at_end=True,
        metric_for_best_model="eval_loss",
        greater_is_better=False,
        logging_steps=10,
        report_to=[],
        fp16=True,
    )

    trainer = Trainer(
        model=model,
        args=training_args,
        train_dataset=tokenized_ds["train"],
        eval_dataset=tokenized_ds["validation"],
        data_collator=DataCollatorForLanguageModeling(
            tokenizer=tokenizer,
            mlm=False
        ),
    )

    # 6. Train and save
    trainer.train()
    
    # 7. Save adapter and verification marker
    best_checkpoint = os.path.join(TRAINED_MODEL_DIR, "best_checkpoint")
    model.save_pretrained(best_checkpoint)
    
    # Save verification marker
    marker_path = os.path.join(best_checkpoint, "finetune_marker.json")
    with open(marker_path, "w") as f:
        json.dump(VERIFICATION_MARKER, f)
    
    # Calculate weight hash
    weights = model.lm_head.weight.data.cpu().numpy()
    weight_hash = hashlib.sha256(weights.tobytes()).hexdigest()[:10]
    logger.info(f"🔐 Model weight verification hash: {weight_hash}")
    
    logger.info("✅ Training complete - model saved")

