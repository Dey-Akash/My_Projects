from flask import Flask, request, render_template_string
import requests

app = Flask(__name__)

HTML = '''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Weather App</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: linear-gradient(to right, #74ebd5, #ACB6E5);
            text-align: center;
            padding: 50px;
        }
        .weather-box {
            background: white;
            padding: 30px;
            border-radius: 12px;
            box-shadow: 0 4px 10px rgba(0,0,0,0.2);
            display: inline-block;
        }
        input[type="text"] {
            padding: 10px;
            width: 250px;
            border-radius: 5px;
            border: 1px solid #ccc;
        }
        button {
            padding: 10px 20px;
            background: #007BFF;
            color: white;
            border: none;
            border-radius: 5px;
            margin-top: 10px;
            cursor: pointer;
        }
        button:hover {
            background: #0056b3;
        }
        .result {
            margin-top: 20px;
            font-size: 20px;
        }
        .icon {
            width: 64px;
            height: 64px;
            vertical-align: middle;
        }
    </style>
</head>
<body>
    <div class="weather-box">
        <h1>Weather App 🌦️</h1>
        <form method="POST">
            <input type="text" name="location" placeholder="Enter location" required>
            <br>
            <button type="submit">Get Weather</button>
        </form>

        {% if temperature %}
            <div class="result">
                <p>📍 <strong>{{ location }}</strong></p>
                <p>🌡️ <strong>{{ temperature }}°C</strong></p>
                <p>
                    <img class="icon" src="{{ icon }}" alt="Weather icon">
                    <strong>{{ condition }}</strong>
                </p>
            </div>
        {% elif error %}
            <div class="result" style="color: red;">{{ error }}</div>
        {% endif %}
    </div>
</body>
</html>
'''

@app.route('/', methods=['GET', 'POST'])
def index():
    temperature = None
    icon = None
    condition = None
    location = None
    error = None

    if request.method == 'POST':
        location = request.form['location']
        api_key = "3010cf45b8a54ebfa7e75606250606"
        url = f"http://api.weatherapi.com/v1/current.json?key={api_key}&q={location}&aqi=yes"

        try:
            response = requests.get(url)
            data = response.json()

            if 'error' in data:
                error = data['error']['message']
            else:
                temperature = data['current']['temp_c']
                condition = data['current']['condition']['text']
                icon = "http:" + data['current']['condition']['icon']
                location = data['location']['name']
        except Exception as e:
            error = "Something went wrong. Please try again."

    return render_template_string(HTML, temperature=temperature, icon=icon,
                                  condition=condition, location=location, error=error)

if __name__ == '__main__':
    app.run(debug=True)
