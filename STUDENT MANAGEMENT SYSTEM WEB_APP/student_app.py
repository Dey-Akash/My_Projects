from flask import Flask, request, render_template_string, redirect, url_for

app = Flask(__name__)

# In-memory storage
students = {}
teachers = {}
departments = []
users = {'admin@university.com': 'admin123'}  # Default user

# HTML templates
LOGIN_HTML = '''
<!DOCTYPE html>
<html>
<head>
    <title>Login | Student Management</title>
    <style>
        body {
            font-family: Arial;
            background: #f0f2f5;
            text-align: center;
            padding-top: 50px;
        }
        .login-box {
            background: white;
            width: 300px;
            margin: auto;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0px 4px 10px rgba(0,0,0,0.3);
        }
        input {
            width: 90%;
            padding: 10px;
            margin: 8px 0;
        }
        button {
            padding: 10px 20px;
            background: #007bff;
            color: white;
            border: none;
            border-radius: 6px;
        }
        img {
            width: 100px;
            margin-bottom: 20px;
        }
    </style>
</head>
<body>
    <div class="login-box">
        <img src="https://cdn-icons-png.flaticon.com/512/3062/3062634.png" alt="University Logo">
        <form method="POST">
            <input type="email" name="email" placeholder="Email" required><br>
            <input type="password" name="password" placeholder="Password" required><br>
            <button type="submit">Login</button>
        </form>
        {% if error %}<p style="color:red">{{ error }}</p>{% endif %}
    </div>
</body>
</html>
'''

DASHBOARD_HTML = '''
<!DOCTYPE html>
<html>
<head>
    <title>Dashboard</title>
    <style>
        body { font-family: sans-serif; background: #eef2f3; text-align: center; padding: 30px; }
        .section { background: white; padding: 20px; margin: 20px auto; width: 80%; border-radius: 10px; box-shadow: 0px 2px 8px rgba(0,0,0,0.1); }
        input, select { padding: 10px; margin: 5px; width: 200px; }
        button { padding: 10px 15px; background: #28a745; color: white; border: none; border-radius: 5px; }
        h2 { color: #333; }
    </style>
</head>
<body>
    <h1>🎓 Student Management System</h1>

    <div class="section">
        <h2>➕ Add Student</h2>
        <form method="POST" action="/add_student">
            <input name="reg_no" placeholder="Reg. Number" required>
            <input name="name" placeholder="Student Name" required>
            <select name="dept" required>
                <option value="">Select Department</option>
                {% for d in departments %}
                <option>{{ d }}</option>
                {% endfor %}
            </select>
            <button type="submit">Add Student</button>
        </form>
    </div>

    <div class="section">
        <h2>➕ Add Teacher</h2>
        <form method="POST" action="/add_teacher">
            <input name="reg_no" placeholder="Teacher Reg. No" required>
            <input name="name" placeholder="Teacher Name" required>
            <select name="dept" required>
                <option value="">Select Department</option>
                {% for d in departments %}
                <option>{{ d }}</option>
                {% endfor %}
            </select>
            <button type="submit">Add Teacher</button>
        </form>
    </div>

    <div class="section">
        <h2>🏫 Add Department</h2>
        <form method="POST" action="/add_department">
            <input name="dept" placeholder="Department Name" required>
            <button type="submit">Add</button>
        </form>
    </div>

    <div class="section">
        <h2>🔍 Search Student</h2>
        <form method="POST" action="/search_student">
            <input name="reg_no" placeholder="Student Reg. No">
            <button type="submit">Search</button>
        </form>
    </div>

    <div class="section">
        <h2>🔍 Search Teacher</h2>
        <form method="POST" action="/search_teacher">
            <input name="reg_no" placeholder="Teacher Reg. No">
            <button type="submit">Search</button>
        </form>
    </div>

    <div class="section">
        <h2>❌ Remove Student</h2>
        <form method="POST" action="/remove_student">
            <input name="reg_no" placeholder="Student Reg. No">
            <button type="submit">Remove</button>
        </form>
    </div>

    {% if message %}
    <div style="color: green; font-weight: bold;">{{ message }}</div>
    {% endif %}
</body>
</html>
'''

@app.route('/', methods=['GET', 'POST'])
def login():
    error = None
    if request.method == 'POST':
        email = request.form['email']
        password = request.form['password']
        if users.get(email) == password:
            return redirect(url_for('dashboard'))
        else:
            error = "Invalid credentials"
    return render_template_string(LOGIN_HTML, error=error)

@app.route('/dashboard')
def dashboard():
    return render_template_string(DASHBOARD_HTML, departments=departments, message=None)

@app.route('/add_student', methods=['POST'])
def add_student():
    reg = request.form['reg_no']
    students[reg] = {
        'name': request.form['name'],
        'dept': request.form['dept']
    }
    return render_template_string(DASHBOARD_HTML, departments=departments, message="✅ Student added")

@app.route('/add_teacher', methods=['POST'])
def add_teacher():
    reg = request.form['reg_no']
    teachers[reg] = {
        'name': request.form['name'],
        'dept': request.form['dept']
    }
    return render_template_string(DASHBOARD_HTML, departments=departments, message="✅ Teacher added")

@app.route('/add_department', methods=['POST'])
def add_department():
    dept = request.form['dept']
    if dept not in departments:
        departments.append(dept)
    return render_template_string(DASHBOARD_HTML, departments=departments, message="✅ Department added")

@app.route('/search_student', methods=['POST'])
def search_student():
    reg = request.form['reg_no']
    s = students.get(reg)
    msg = f"🎓 {reg}: {s['name']} ({s['dept']})" if s else "❌ Student not found"
    return render_template_string(DASHBOARD_HTML, departments=departments, message=msg)

@app.route('/search_teacher', methods=['POST'])
def search_teacher():
    reg = request.form['reg_no']
    t = teachers.get(reg)
    msg = f"👨‍🏫 {reg}: {t['name']} ({t['dept']})" if t else "❌ Teacher not found"
    return render_template_string(DASHBOARD_HTML, departments=departments, message=msg)

@app.route('/remove_student', methods=['POST'])
def remove_student():
    reg = request.form['reg_no']
    if reg in students:
        del students[reg]
        msg = "✅ Student removed"
    else:
        msg = "❌ Student not found"
    return render_template_string(DASHBOARD_HTML, departments=departments, message=msg)

if __name__ == '__main__':
    app.run(debug=True)
