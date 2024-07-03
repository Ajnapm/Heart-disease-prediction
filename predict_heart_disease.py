import pandas as pd
from sklearn.ensemble import RandomForestClassifier
from sklearn.impute import SimpleImputer
from sklearn.pipeline import Pipeline
from sklearn.compose import ColumnTransformer
from sklearn.preprocessing import OneHotEncoder, StandardScaler

# Load the dataset
df = pd.read_csv("mpro/heart_disease.csv")
y = df["Heart Disease"]
x = df.drop("Heart Disease", axis=1)
numeric_feature = x.select_dtypes(include=['int64', 'float64']).columns
categorical_feature = x.select_dtypes(include=['object']).columns

# Preprocessing pipeline
numeric_transformer = Pipeline(steps=[
    ('imputer', SimpleImputer(strategy='median')),
    ('scaler', StandardScaler())])

categorical_transformer = Pipeline(steps=[
    ('imputer', SimpleImputer(strategy='most_frequent')),
    ('onehot', OneHotEncoder())])

preprocessor = ColumnTransformer(transformers=[
    ('num', numeric_transformer, numeric_feature),
    ('cat', categorical_transformer, categorical_feature)])

# Model
rf = Pipeline(steps=[
    ('preprocessor', preprocessor),
    ('classifier', RandomForestClassifier(n_estimators=100, random_state=42))])

# Fit the model
rf.fit(x, y)

# Define the predict_heart_disease function here directly
def predict_heart_disease(user_input):
    user_data = pd.DataFrame.from_dict([user_input])
    user_data = user_data.reindex(columns=x.columns, fill_value=0)  # Fill missing columns with zeros
    prediction = rf.predict(user_data)[0]
    return prediction

# Now you can use predict_heart_disease function in this script without importing
