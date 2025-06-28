from flask import Flask, render_template_string, request
import random

app = Flask(__name__)

HTML = '''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Snake Water Gun Game</title>
    <style>
        body {
            font-family: 'Segoe UI', sans-serif;
            background: linear-gradient(to right, #f9d423, #ff4e50);
            text-align: center;
            padding: 50px;
        }
        .game-box {
            background-color: #fff;
            padding: 30px;
            border-radius: 10px;
            display: inline-block;
            box-shadow: 0 4px 12px rgba(0,0,0,0.2);
        }
        h1 {
            margin-bottom: 20px;
        }
        form button {
            padding: 12px 25px;
            margin: 10px;
            font-size: 16px;
            background-color: #007BFF;
            border: none;
            color: white;
            border-radius: 6px;
            cursor: pointer;
        }
        form button:hover {
            background-color: #0056b3;
        }
        .result {
            margin-top: 30px;
            font-size: 20px;
            color: #333;
        }
    </style>
</head>
<body>
    <div class="game-box">
        <h1>🎮 Snake, Water, Gun</h1>
        <form method="POST">
            <button name="choice" value="snake">🐍 Snake</button>
            <button name="choice" value="water">💧 Water</button>
            <button name="choice" value="gun">🔫 Gun</button>
        </form>

        {% if result %}
            <div class="result">
                <p>You chose: <strong>{{ user_choice }}</strong></p>
                <p>Computer chose: <strong>{{ computer_choice }}</strong></p>
                <p>🎉 Result: <strong>{{ result }}</strong></p>
            </div>
        {% endif %}
    </div>
</body>
</html>
'''

def get_winner(user, comp):
    if user == comp:
        return "It's a Tie!"
    elif (user == 'snake' and comp == 'water') or \
         (user == 'water' and comp == 'gun') or \
         (user == 'gun' and comp == 'snake'):
        return "You Win!"
    else:
        return "You Lose!"

@app.route('/', methods=['GET', 'POST'])
def game():
    result = None
    user_choice = None
    computer_choice = None

    if request.method == 'POST':
        user_choice = request.form['choice']
        computer_choice = random.choice(['snake', 'water', 'gun'])
        result = get_winner(user_choice, computer_choice)

    return render_template_string(HTML, result=result,
                                  user_choice=user_choice,
                                  computer_choice=computer_choice)

if __name__ == '__main__':
    app.run(debug=True)
