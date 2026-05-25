import matplotlib
matplotlib.use('Agg')  # Avoid display issues

import os

import io
import time
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import shap
from flask import Flask, render_template, request, send_file, session
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder, StandardScaler, MinMaxScaler
from sklearn.metrics import accuracy_score, mean_squared_error, roc_curve, auc, precision_score, recall_score, f1_score, r2_score, mean_absolute_error
from sklearn.feature_selection import VarianceThreshold
from sklearn.ensemble import RandomForestClassifier, RandomForestRegressor, GradientBoostingClassifier, GradientBoostingRegressor
from sklearn.svm import SVC, SVR
try:
    from xgboost import XGBClassifier, XGBRegressor
except ImportError:
    XGBClassifier = None
    XGBRegressor = None
from lightgbm import LGBMClassifier, LGBMRegressor
from catboost import CatBoostClassifier, CatBoostRegressor
from sklearn.neural_network import MLPClassifier, MLPRegressor
from sklearn.naive_bayes import GaussianNB
from sklearn.tree import DecisionTreeClassifier, DecisionTreeRegressor
from sklearn.linear_model import LogisticRegression, LinearRegression, BayesianRidge
from sklearn.neighbors import KNeighborsClassifier, KNeighborsRegressor
from sklearn.semi_supervised import SelfTrainingClassifier
from fpdf import FPDF
from firebase_admin import credentials, db
import firebase_admin
import requests
from urllib.parse import urlparse

app = Flask(__name__)
UPLOAD_FOLDER = 'uploads'
STATIC_FOLDER = 'static'
os.makedirs(UPLOAD_FOLDER, exist_ok=True)
os.makedirs(STATIC_FOLDER, exist_ok=True)
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
app.secret_key = 'change_this_to_a_secret_key'

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/automl')
def automl():
    return render_template('AutoML_app.html')

@app.route('/load_columns_from_url', methods=['POST'])
def load_columns_from_url():
    dataset_url = request.form.get('dataset_url')
    try:
        response = requests.get(dataset_url)
        response.raise_for_status()
        csv_content = response.text

        # Debug: print first few lines to check content
        print("First 200 chars of CSV:", csv_content[:200])

        # Try default read
        try:
            df = pd.read_csv(io.StringIO(csv_content))
        except pd.errors.ParserError:
            # Try with semicolon separator
            df = pd.read_csv(io.StringIO(csv_content), sep=';')
        
        columns = df.columns.tolist()
        # If columns are Unnamed, try header=None
        if all([str(col).startswith('Unnamed') for col in columns]):
            df = pd.read_csv(io.StringIO(csv_content), header=None)
            columns = df.columns.tolist()
        return {'columns': columns}
    except requests.exceptions.RequestException as e:
        return {'error': f'Erreur lors de la récupération du fichier depuis l\'URL: {e}'}, 400
    except pd.errors.EmptyDataError:
        return {'error': 'Le fichier CSV à l\'URL est vide.'}, 400
    except pd.errors.ParserError:
        return {'error': 'Erreur lors de l\'analyse du fichier CSV depuis l\'URL. Assurez-vous que le format est correct.'}, 400
    except Exception as e:
        return {'error': f'Une erreur inattendue s\'est produite: {e}'}, 500


@app.route('/upload', methods=['POST'])
def upload():
    upload_type = request.form.get('uploadType')
    task = request.form['task']
    target = request.form['target']
    filepath = None

    if upload_type == 'local':
        file = request.files['file']
        filepath = os.path.join(app.config['UPLOAD_FOLDER'], file.filename)
        file.save(filepath)
        df = pd.read_csv(filepath)
    elif upload_type == 'url':
        dataset_url = request.form['dataset_url']
        try:
            response = requests.get(dataset_url)
            response.raise_for_status()
            csv_content = response.text
            df = pd.read_csv(io.StringIO(csv_content))
        except requests.exceptions.RequestException as e:
            return render_template('AutoML_app.html', error=f'Erreur lors de la récupération du fichier depuis l\'URL: {e}')
        except pd.errors.EmptyDataError:
            return render_template('AutoML_app.html', error='Le fichier CSV à l\'URL est vide.')
        except pd.errors.ParserError:
            return render_template('AutoML_app.html', error='Erreur lors de l\'analyse du fichier CSV depuis l\'URL. Assurez-vous que le format est correct.')
        except Exception as e:
            return render_template('AutoML_app.html', error=f'Une erreur inattendue s\'est produite: {e}')
    else:
        return render_template('AutoML_app.html', error='Type de chargement non reconnu.')

    # --- Data Preprocessing (as before) ---
    for col in df.columns:
        if df[col].dtype in ['int64', 'float64']:
            df[col].fillna(df[col].median(), inplace=True)
        else:
            df[col].fillna(df[col].mode()[0], inplace=True)

    df = df.drop_duplicates()

    for col in df.select_dtypes(include='object').columns:
        df[col] = LabelEncoder().fit_transform(df[col])

    def traiter_outliers(df, seuil=3, seuil_proportion=0.1):
        from scipy.stats import zscore
        numeric_cols = df.select_dtypes(include=['number']).columns
        for col in numeric_cols:
            z_scores = zscore(df[col])
            outliers = (abs(z_scores) > seuil)
            proportion = outliers.mean()
            if proportion > seuil_proportion:
                df.loc[outliers, col] = df[col].median()
        return df

    df = traiter_outliers(df)

    X = df.drop(columns=[target]) if task != 'clustering' else df
    y = df[target] if task != 'clustering' else None

    def remove_low_variance_features(X, threshold=0.01):
        selector = VarianceThreshold(threshold)
        selector.fit(X)
        return X[X.columns[selector.get_support(indices=True)]]

    def remove_highly_correlated_features(X, threshold=0.95):
        corr_matrix = X.corr().abs()
        upper = corr_matrix.where(np.triu(np.ones(corr_matrix.shape), k=1).astype(bool))
        to_drop = [column for column in upper.columns if any(upper[column] > threshold)]
        return X.drop(columns=to_drop)

    X = remove_low_variance_features(X)
    X = remove_highly_correlated_features(X)

    scaler = StandardScaler()
    X[X.columns] = scaler.fit_transform(X)

    results = []
    best_score = -float('inf') if task == 'classification' else float('inf')
    best_model = None
    best_model_name = ""
    model_scores = {}
    visualization_paths = {}
    all_model_results = [] # To store results of all models

    if task != 'clustering':
        X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

        models = {
            'classification': [
                ("Logistic Regression", LogisticRegression(max_iter=1000)),
                ("Decision Tree", DecisionTreeClassifier()),
                ("Random Forest", RandomForestClassifier()),
                ("Gradient Boosting", GradientBoostingClassifier()),
                ("SVM", SVC(probability=True)),
                ("KNN", KNeighborsClassifier()),
                ("Naive Bayes", GaussianNB()),
                ("Self-Training Classifier", SelfTrainingClassifier(LogisticRegression(max_iter=1000))),
                ("CatBoost", CatBoostClassifier(silent=True)),
                ("XGBoost", XGBClassifier()),
                ("LightGBM", LGBMClassifier())
            ],
            'regression': [
                ("Linear Regression", LinearRegression()),
                ("Decision Tree", DecisionTreeRegressor()),
                ("Random Forest", RandomForestRegressor()),
                ("Gradient Boosting", GradientBoostingRegressor()),
                ("SVM", SVR()),
                ("KNN", KNeighborsRegressor()),
                ("Neural Networks", MLPRegressor(max_iter=1000)),
                ("Bayesian Regression", BayesianRidge()),
                ("CatBoost", CatBoostRegressor(silent=True)),
                ("XGBoost", XGBRegressor()),
                ("LightGBM", LGBMRegressor())
            ]
        }

        model_details = {}
        for name, model in models[task]:
            start_time = time.time()
            model.fit(X_train, y_train)
            training_time = time.time() - start_time
            preds = model.predict(X_test)

            model_result = {'name': name, 'training_time': training_time}

            if task == 'classification':
                score = accuracy_score(y_test, preds)
                model_result['accuracy'] = round(score, 4)
                probas = model.predict_proba(X_test)[:, 1]
                fpr, tpr, _ = roc_curve(y_test, probas)
                roc_auc = auc(fpr, tpr)
                precision = precision_score(y_test, preds)
                recall = recall_score(y_test, preds)
                f1 = f1_score(y_test, preds)
                model_result['roc_auc'] = round(roc_auc, 4)
                model_result['precision'] = round(precision, 4)
                model_result['recall'] = round(recall, 4)
                model_result['f1'] = round(f1, 4)
            else:
                score = mean_squared_error(y_test, preds)
                r2 = r2_score(y_test, preds)
                mae = mean_absolute_error(y_test, preds)
                model_result['mse'] = round(score, 4)
                model_result['r2'] = round(r2, 4)
                model_result['mae'] = round(mae, 4)

            all_model_results.append(model_result)

            # Store model details (for the best model later)
            model_details[name] = {
                'training_time': training_time,
                'params': model.get_params(),
                'score': score,
                'metrics': {
                    'precision': precision if task == 'classification' else None,
                    'recall': recall if task == 'classification' else None,
                    'f1': f1 if task == 'classification' else None,
                    'roc_auc': roc_auc if task == 'classification' else None,
                    'r2': r2 if task == 'regression' else None,
                    'mae': mae if task == 'regression' else None
                }
            }

            if (task == 'classification' and score > best_score) or (task == 'regression' and score < best_score):
                best_score = score
                best_model = model
                best_model_name = name
                best_training_time = training_time
                best_model_params = model.get_params()
                best_model_type = type(model).__name__

        # Prepare evaluation metrics for the best model
        evaluation_metrics = {}
        if task == 'classification':
            evaluation_metrics = {
                'Precision': round(precision, 4),
                'Recall': round(recall, 4),
                'F1 Score': round(f1, 4),
                'ROC AUC': round(roc_auc, 4)
            }
        else:
            evaluation_metrics = {
                'R² Score': round(r2, 4),
                'MAE': round(mae, 4),
                'MSE': round(score, 4)
            }

        # Calculate parameter count for the best model
        if hasattr(best_model, 'n_features_in_'):
            param_count = best_model.n_features_in_
        elif hasattr(best_model, 'coef_'):
            param_count = len(best_model.coef_)
        else:
            param_count = 'N/A'

        session.update({
            'model_scores': model_scores,
            'best_model_name': best_model_name,
            'best_score': best_score,
            'best_training_time': best_training_time,
            'best_model_params_count': param_count,
            'best_model_type': best_model_type,
            'best_model_hyperparams': best_model_params,
            'evaluation_metrics': evaluation_metrics
        })

        # --- Visualization code (as before) ---
        if hasattr(best_model, 'feature_importances_'):
            plt.figure(figsize=(10, 6))
            importances = best_model.feature_importances_
            features = X.columns
            indices = np.argsort(importances)[::-1]
            plt.title("Feature Importances")
            plt.barh(range(len(indices)), importances[indices], align='center')
            plt.yticks(range(len(indices)), [features[i] for i in indices])
            plt.xlabel('Relative Importance')
            feat_path = os.path.join(STATIC_FOLDER, 'feature_importance.png')
            plt.savefig(feat_path)
            plt.close()
            visualization_paths['feature_importance_path'] = 'feature_importance.png'

        if task == 'classification':
            try:
                plt.figure()
                y_prob = best_model.predict_proba(X_test)[:, 1]
                fpr, tpr, _ = roc_curve(y_test, y_prob)
                roc_auc = auc(fpr, tpr)
                plt.plot(fpr, tpr, label=f'AUC = {roc_auc:.2f}')
                plt.plot([0, 1], [0, 1], 'k--')
                plt.xlabel('False Positive Rate')
                plt.ylabel('True Positive Rate')
                plt.title('ROC Curve')
                roc_path = os.path.join(STATIC_FOLDER, 'roc_curve.png')
                plt.savefig(roc_path)
                plt.close()
                visualization_paths['roc_curve_path'] = 'roc_curve.png'
            except Exception as e:
                print("ROC Error:", e)

            try:
                explainer = shap.Explainer(best_model, X_train)
                shap_values = explainer(X_test)
                shap.summary_plot(shap_values, X_test, plot_type="bar", show=False)
                shap_path = os.path.join(STATIC_FOLDER, 'shap_summary.png')
                plt.savefig(shap_path)
                plt.close()
                visualization_paths['shap_plot_path'] = 'shap_summary.png'
            except Exception as e:
                print("SHAP Error:", e)

        elif task == 'regression':
            y_pred = best_model.predict(X_test)
            
            # Plot actual vs predicted
            plt.figure()
            plt.scatter(y_test, y_pred, alpha=0.6)
            plt.xlabel("Actual")
            plt.ylabel("Predicted")
            plt.title("Actual vs Predicted Values")
            reg_plot_path = os.path.join(STATIC_FOLDER, 'regression_plot.png')
            plt.savefig(reg_plot_path)
            plt.close()
            visualization_paths['regression_plot_path'] = 'regression_plot.png'

            # SHAP summary plot
            try:
                explainer = shap.Explainer(best_model, X_train)
                shap_values = explainer(X_test)
                shap.summary_plot(shap_values, X_test, plot_type="bar", show=False)
                shap_path = os.path.join(STATIC_FOLDER, 'shap_summary.png')
                plt.savefig(shap_path)
                plt.close()
                visualization_paths['shap_plot_path'] = 'shap_summary.png'
            except Exception as e:
                print("SHAP Error (regression):", e)


            residuals = y_test - y_pred
            plt.figure()
            plt.scatter(y_pred, residuals)
            plt.axhline(0, color='k', linestyle='--')
            plt.xlabel('Predicted')
            plt.ylabel('Residuals')
            plt.title('Residual Plot')
            resid_path = os.path.join(STATIC_FOLDER, 'residual_plot.png')
            plt.savefig(resid_path)
            plt.close()
            visualization_paths['residual_plot_path'] = 'residual_plot.png'

    return render_template(
        "results.html",
        best_training_time=best_training_time,
        best_model_hyperparams=best_model_params,
        evaluation_metrics=evaluation_metrics,
        **visualization_paths,
        results=results,
        task=task,
        best_model_name=best_model_name,
        best_score=round(best_score, 4) if task != 'clustering' else 'N/A',
        model_scores=model_scores,
        all_model_results=all_model_results # Pass the list of all model results to the template
    )

# Firebase
cred = credentials.Certificate("chatbot-eddb6-firebase-adminsdk-fbsvc-f7373bcd72.json")
firebase_admin.initialize_app(cred, {
    'databaseURL': 'https://chatbot-eddb6-default-rtdb.firebaseio.com/'
})

def send_message_to_chatbot(message):
    ref = db.reference("chat")
    chat_id = str(int(time.time()))
    ref.child(chat_id).set({
        "message": message,
        "response": ""
    })
    return chat_id

def get_chatbot_response(chat_id):
    ref = db.reference(f"chat/{chat_id}")
    time.sleep(2)
    response = f"Réponse automatique à: {chat_id}"
    ref.update({"response": response})

@app.route('/download_report', methods=['POST'])
def download_report():
    from flask import make_response, send_file
    from fpdf import FPDF
    import os
    from flask import session, request

    STATIC_FOLDER = 'static'  # Assuming 'static' is defined

    model_scores = session.get('model_scores', {})
    best_model_name = session.get('best_model_name', 'N/A')
    best_score = session.get('best_score', 'N/A')
    best_training_time = session.get('best_training_time', 'N/A')
    best_model_params_count = session.get('best_model_params_count', 'N/A')
    best_model_type = session.get('best_model_type', 'N/A')
    best_model_hyperparams = session.get('best_model_hyperparams', {})
    evaluation_metrics = session.get('evaluation_metrics', {})
    task = request.form.get('task', 'N/A')

    class PDF(FPDF):
        def __init__(self, **kwargs):
            super().__init__(**kwargs)

        def header(self):
            self.set_font("Arial", "", 16)
            self.set_text_color(30, 30, 30)
            self.cell(0, 10, "Rapport d'Analyse AutoML", border=False, ln=True, align='C')
            self.ln(5)

        def section_title(self, title):
            self.set_font("Arial", "B", 14)
            self.set_text_color(0, 70, 130)
            self.cell(0, 10, title, ln=True)
            self.set_draw_color(0, 70, 130)
            self.set_line_width(0.5)
            self.line(self.get_x(), self.get_y(), 200, self.get_y())
            self.ln(4)

        def section_text(self, text):
            self.set_font("Arial", "", 12)  # Reduced font size slightly
            self.set_text_color(0, 0, 0)
            self.multi_cell(0, 6, text)  # Reduced cell height slightly
            self.ln(2)

    pdf = PDF()
    pdf.add_page()

    # Résumé du meilleur modèle
    pdf.section_title("Informations sur le meilleur modèle")
    pdf.section_text(f"Nom du modèle \u00A0\u00A0\u00A0 : {best_model_name}")
    pdf.section_text(f"Type de modèle \u00A0\u00A0\u00A0: {best_model_type}")
    pdf.section_text(f"Score de performance: {round(best_score, 4)}")
    pdf.section_text(f"Durée d'entraînement: {best_training_time:.2f} secondes")
    pdf.section_text(f"Nombre de paramètres: {best_model_params_count}")

    # Hyperparamètres
    pdf.section_title("Hyperparamètres du meilleur modèle")
    for key, value in best_model_hyperparams.items():
        pdf.section_text(f"- {key}: {value}")  # Changed bullet point for better compatibility

    # Métriques d'évaluation
    pdf.section_title("Métriques d'évaluation")
    for key, value in evaluation_metrics.items():
        pdf.section_text(f"- {key}: {value}")

    # Visualisations (si elles existent)
    image_paths = {
        'Courbe ROC': os.path.join(STATIC_FOLDER, 'roc_curve.png'),
        'Importance des variables': os.path.join(STATIC_FOLDER, 'feature_importance.png'),
        'SHAP summary': os.path.join(STATIC_FOLDER, 'shap_summary.png'),
        'Prédiction vs Réel': os.path.join(STATIC_FOLDER, 'pred_vs_actual.png'),
        'Résidus': os.path.join(STATIC_FOLDER, 'residual_plot.png'),
    }

    for title, path in image_paths.items():
        if os.path.exists(path):
            pdf.add_page()
            pdf.section_title(title)
            try:
                pdf.image(path, w=180)
            except Exception as e:
                pdf.section_text(f"Erreur lors de l'insertion de l'image '{title}': {e}")

    # Sauvegarde
    pdf_output_path = os.path.join(STATIC_FOLDER, 'rapport_automl.pdf')
    try:
        pdf.output(pdf_output_path, 'F')  # 'F' saves to a local file
        return send_file(pdf_output_path, as_attachment=True)
    except Exception as e:
        return f"Erreur lors de la génération du PDF: {e}"


if __name__ == '__main__':
    app.run(debug=True)