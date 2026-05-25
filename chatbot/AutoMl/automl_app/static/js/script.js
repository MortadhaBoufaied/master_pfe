// Toggle between light and dark themes
function toggleTheme() {
  const html = document.documentElement;
  const currentTheme = html.getAttribute("data-bs-theme");
  html.setAttribute("data-bs-theme", currentTheme === "dark" ? "light" : "dark");
}

// Toggle the chatbox visibility
function toggleChatbox() {
  const chatbox = document.getElementById("chatbox");
  if (chatbox) {
    chatbox.style.display = chatbox.style.display === "flex" ? "none" : "flex";
  }
}

// Run after DOM is loaded
document.addEventListener("DOMContentLoaded", function () {
  const localOption = document.getElementById("localOption");
  const urlOption = document.getElementById("urlOption");
  const localUploadDiv = document.getElementById("localUpload");
  const urlUploadDiv = document.getElementById("urlUpload");
  const datasetUrlInput = document.getElementById("datasetUrl");
  const targetContainer = document.getElementById("targetContainer");
  const targetSelect = document.getElementById("targetSelect");
  const csvFileInput = document.getElementById("csvFile");
  const gifButton = document.getElementById("gifButton");
  const automlForm = document.getElementById("automlForm");
  const loaderDiv = document.getElementById("loader");
  const successMessage = document.getElementById("successMessage");
  const errorMessage = document.getElementById("errorMessage");
  const chatbotButton = document.getElementById("chatbot-button");

  // Handle success/error messages timeout
  if (successMessage) {
    setTimeout(() => (successMessage.style.display = "none"), 5000);
  }
  if (errorMessage) {
    setTimeout(() => (errorMessage.style.display = "none"), 5000);
  }

  // Toggle upload option visibility
  window.toggleUploadOption = function () {
    if (localOption?.checked) {
      localUploadDiv.style.display = "block";
      urlUploadDiv.style.display = "none";
    } else if (urlOption?.checked) {
      localUploadDiv.style.display = "none";
      urlUploadDiv.style.display = "block";
    }
    targetContainer.style.display = "none";
    targetSelect.innerHTML = '<option value="">-- Choisir --</option>';
  };

  // Load columns from local CSV file
  window.loadColumns = function () {
    const file = csvFileInput?.files?.[0];
    if (file) {
      const formData = new FormData();
      formData.append("file", file);

      fetch("/load_columns", {
        method: "POST",
        body: formData,
      })
        .then((response) => response.json())
        .then((data) => {
          targetSelect.innerHTML = '<option value="">-- Choisir --</option>';
          if (data.columns) {
            data.columns.forEach((column) => {
              const option = document.createElement("option");
              option.value = column;
              option.textContent = column;
              targetSelect.appendChild(option);
            });
            targetContainer.style.display = "block";
          } else if (data.error) {
            alert(data.error);
            targetContainer.style.display = "none";
          }
        })
        .catch((error) => {
          console.error("Erreur:", error);
          alert("Une erreur s'est produite lors du chargement des colonnes.");
          targetContainer.style.display = "none";
          targetSelect.innerHTML = '<option value="">-- Choisir --</option>';
        });
    } else {
      targetContainer.style.display = "none";
      targetSelect.innerHTML = '<option value="">-- Choisir --</option>';
    }
  };

  // Debounce function for URL input
  function debounce(func, delay) {
    let timeout;
    return function () {
      clearTimeout(timeout);
      timeout = setTimeout(() => func.apply(this, arguments), delay);
    };
  }

  // Load columns from dataset URL
  if (datasetUrlInput) {
    datasetUrlInput.addEventListener(
      "input",
      debounce(function () {
        if (urlOption?.checked && this.value.trim() !== "") {
          fetch("/load_columns_from_url", {
            method: "POST",
            headers: {
              "Content-Type": "application/x-www-form-urlencoded",
            },
            body: `dataset_url=${encodeURIComponent(this.value)}`,
          })
            .then((response) => response.json())
            .then((data) => {
              targetSelect.innerHTML = '<option value="">-- Choisir --</option>';
              if (data.columns) {
                data.columns.forEach((column) => {
                  const option = document.createElement("option");
                  option.value = column;
                  option.textContent = column;
                  targetSelect.appendChild(option);
                });
                targetContainer.style.display = "block";
              } else if (data.error) {
                alert(data.error);
                targetContainer.style.display = "none";
              }
            })
            .catch((error) => {
              console.error("Erreur:", error);
              alert(
                "Une erreur s'est produite lors du chargement des colonnes depuis l'URL."
              );
              targetContainer.style.display = "none";
              targetSelect.innerHTML = '<option value="">-- Choisir --</option>';
            });
        } else {
          targetContainer.style.display = "none";
          targetSelect.innerHTML = '<option value="">-- Choisir --</option>';
        }
      }, 600)
    );
  }

  // Show loader on form submit
  window.showLoader = function () {
    if (loaderDiv) loaderDiv.style.display = "block";
  };

  if (automlForm) {
    automlForm.addEventListener("submit", function () {
      showLoader();
    });
  }

  // Trigger file input on button click
  if (gifButton && csvFileInput) {
    gifButton.addEventListener("click", function () {
      csvFileInput.click();
    });
  }

  // Chatbot toggle button
  if (chatbotButton) {
    chatbotButton.addEventListener("click", toggleChatbox);
  }

  // Initialize upload view
  toggleUploadOption();
});
