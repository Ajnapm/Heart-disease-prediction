from kivy.app import App
from kivy.uix.boxlayout import BoxLayout
from kivy.uix.label import Label
from kivy.uix.textinput import TextInput
from kivy.uix.button import Button
import numpy as np

# Import the function for predicting heart disease
from predict_heart_disease import predict_heart_disease

class HeartDiseaseChatbot(App):
    def build(self):
        self.layout = BoxLayout(orientation='vertical')
        
        # Add labels and text inputs for each feature
        for feature in ['Age', 'Sex', 'Chest pain type', 'BP', 'Cholesterol', 'FBS over 120', 'EKG results', 'Max HR', 'Exercise angina', 'ST depression', 'Slope of ST', 'Number of vessels fluro', 'Thallium']:
            label = Label(text=feature + ':')
            self.layout.add_widget(label)
            text_input = TextInput()
            self.layout.add_widget(text_input)
        
        # Add predict button
        predict_button = Button(text='Predict')
        predict_button.bind(on_press=self.predict)
        self.layout.add_widget(predict_button)
        
        # Add label for displaying prediction result
        self.prediction_label = Label()
        self.layout.add_widget(self.prediction_label)
        
        return self.layout
    
    def predict(self, instance):
        # Get user input from text inputs
        user_input = []
        for i in range(13):
            text_input = self.layout.children[2 * i + 1]
            user_input.append(float(text_input.text))
        user_input = np.array(user_input).reshape(1, -1)
        
        # Make prediction
        predicted_label = predict_heart_disease(user_input)
        
        # Display prediction result
        if predicted_label == Presence:
            self.prediction_label.text = "Likely to have heart disease."
        else:
            self.prediction_label.text = "Unlikely to have heart disease."

if __name__ == '__main__':
    HeartDiseaseChatbot().run()
