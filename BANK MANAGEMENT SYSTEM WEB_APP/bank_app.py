from flask import Flask, request, render_template_string, redirect
app = Flask(__name__)

# Simulated in-memory database
accounts = {}

HTML = '''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Bank Management System</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: linear-gradient(to right, #fbc2eb, #a6c1ee);
            padding: 40px;
            text-align: center;
        }
        .container {
            background-color: #fff;
            border-radius: 10px;
            padding: 25px;
            margin: auto;
            width: 80%;
            box-shadow: 0 5px 15px rgba(0,0,0,0.2);
        }
        form {
            margin: 20px 0;
        }
        input, select {
            padding: 10px;
            margin: 5px;
            width: 200px;
        }
        button {
            padding: 10px 20px;
            margin-top: 10px;
            background: #007BFF;
            color: white;
            border: none;
            border-radius: 6px;
        }
        h2 {
            color: #333;
        }
        .result {
            margin-top: 20px;
            font-weight: bold;
            color: green;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🏦 Bank Management System</h1>

        <h2>Create Account</h2>
        <form method="POST" action="/create">
            <input name="acc_no" placeholder="Account Number" required>
            <input name="name" placeholder="Account Holder Name" required>
            <select name="acc_type" required>
                <option value="">Select Type</option>
                <option value="Saving">Saving</option>
                <option value="Current">Current</option>
            </select>
            <input name="amount" type="number" placeholder="Initial Amount" required>
            <button type="submit">Create</button>
        </form>

        <h2>View Balance</h2>
        <form method="POST" action="/balance">
            <input name="acc_no" placeholder="Account Number" required>
            <button type="submit">Show Balance</button>
        </form>

        <h2>Add Balance</h2>
        <form method="POST" action="/add">
            <input name="acc_no" placeholder="Account Number" required>
            <input name="amount" type="number" placeholder="Amount to Add" required>
            <button type="submit">Add</button>
        </form>

        <h2>Withdraw Amount</h2>
        <form method="POST" action="/withdraw">
            <input name="acc_no" placeholder="Account Number" required>
            <input name="amount" type="number" placeholder="Amount to Withdraw" required>
            <button type="submit">Withdraw</button>
        </form>

        <h2>Delete Account</h2>
        <form method="POST" action="/delete">
            <input name="acc_no" placeholder="Account Number" required>
            <button type="submit">Delete</button>
        </form>

        {% if message %}
        <div class="result">{{ message }}</div>
        {% endif %}
    </div>
</body>
</html>
'''

@app.route('/', methods=['GET'])
def home():
    return render_template_string(HTML, message=None)

@app.route('/create', methods=['POST'])
def create():
    acc_no = request.form['acc_no']
    if acc_no in accounts:
        return render_template_string(HTML, message="❌ Account already exists!")
    accounts[acc_no] = {
        'name': request.form['name'],
        'type': request.form['acc_type'],
        'balance': float(request.form['amount'])
    }
    return render_template_string(HTML, message="✅ Account created successfully!")

@app.route('/balance', methods=['POST'])
def balance():
    acc_no = request.form['acc_no']
    acc = accounts.get(acc_no)
    if acc:
        msg = f"💰 Balance for {acc['name']} ({acc_no}): ₹{acc['balance']}"
    else:
        msg = "❌ Account not found!"
    return render_template_string(HTML, message=msg)

@app.route('/add', methods=['POST'])
def add():
    acc_no = request.form['acc_no']
    amt = float(request.form['amount'])
    if acc_no in accounts:
        accounts[acc_no]['balance'] += amt
        msg = f"✅ ₹{amt} added! New Balance: ₹{accounts[acc_no]['balance']}"
    else:
        msg = "❌ Account not found!"
    return render_template_string(HTML, message=msg)

@app.route('/withdraw', methods=['POST'])
def withdraw():
    acc_no = request.form['acc_no']
    amt = float(request.form['amount'])
    if acc_no in accounts:
        if accounts[acc_no]['balance'] >= amt:
            accounts[acc_no]['balance'] -= amt
            msg = f"✅ ₹{amt} withdrawn! New Balance: ₹{accounts[acc_no]['balance']}"
        else:
            msg = "❌ Insufficient balance!"
    else:
        msg = "❌ Account not found!"
    return render_template_string(HTML, message=msg)

@app.route('/delete', methods=['POST'])
def delete():
    acc_no = request.form['acc_no']
    if acc_no in accounts:
        del accounts[acc_no]
        msg = "✅ Account deleted successfully!"
    else:
        msg = "❌ Account not found!"
    return render_template_string(HTML, message=msg)

if __name__ == '__main__':
    app.run(debug=True)
