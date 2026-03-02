from flask import Flask, render_template, request, redirect, url_for, session
import pyodbc
import uuid

app = Flask(__name__)
app.secret_key = "your_secret_key_here"

# ----------------------------
# DATABASE CONNECTION
# ----------------------------
def get_connection():
    return pyodbc.connect(
        'DRIVER={ODBC Driver 18 for SQL Server};'
        'SERVER=SRIRAMSAMPARA\\SQLEXPRESS;'
        'DATABASE=HospitalDB02;'
        'Trusted_Connection=yes;'
        'TrustServerCertificate=yes;'
    )

# =========================
# VIEW DOCTORS (Protected)
# =========================
@app.route('/view_doctors')
def view_doctors():
    if 'user_id' not in session:
        return redirect(url_for('home'))

    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("""
        SELECT *
        FROM Doctors
        WHERE IsDeleted = 0 AND IsActive = 1
        ORDER BY DoctorID DESC
    """)

    doctors = cursor.fetchall()
    conn.close()

    return render_template('view_doctors.html', doctors=doctors)

# ----------------------------
# LOGIN PAGE (GET)
# ----------------------------
@app.route('/')
def home():
    return render_template('login.html')

# ----------------------------
# REGISTER PAGE (GET)
# ----------------------------
@app.route('/register')
def register():
    return render_template('register.html')

# ----------------------------
# REGISTER USER (POST)
# ----------------------------
@app.route('/register', methods=['POST'])
def register_user():
    full_name = request.form['full_name'].strip()
    email = request.form['email'].strip()
    password = request.form['password'].strip()

    user_id = str(uuid.uuid4())

    conn = get_connection()
    cursor = conn.cursor()

    try:
        cursor.execute("""
            EXEC Hos_Users_SignUp 
                @UserID=?,
                @FullName=?,
                @Email=?,
                @PasswordHash=?,
                @UserProfile=?
        """, (user_id, full_name, email, password, 'WebApp'))

        conn.commit()
        return redirect(url_for('home'))

    except Exception as e:
        conn.rollback()
        return f"Error: {str(e)}"

    finally:
        conn.close()

# ----------------------------
# LOGIN AUTHENTICATION (POST)
# ----------------------------
@app.route('/login', methods=['POST'])
def login():
    email = request.form['email'].strip()
    password = request.form['password'].strip()

    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("""
        SELECT UserID, FullName
        FROM Users
        WHERE Email = ?
          AND PasswordHash = ?
          AND IsActive = 1
          AND IsDeleted = 0
    """, (email, password))

    user = cursor.fetchone()

    if user:
        session['user_id'] = user.UserID
        session['full_name'] = user.FullName
        conn.close()
        return redirect(url_for('dashboard'))

    conn.close()
    return "Invalid Email or Password"

# =========================
# LOGIN HISTORY (Protected)
# =========================
@app.route('/login_history')
def login_history():

    if 'user_id' not in session:
        return redirect(url_for('home'))

    conn = get_connection()
    cursor = conn.cursor()

    # Call Stored Procedure
    cursor.execute("EXEC dbo.Hos_LoginHistory_GetAll")

    # Convert result to dictionary format
    columns = [column[0] for column in cursor.description]
    history = [dict(zip(columns, row)) for row in cursor.fetchall()]

    conn.close()

    return render_template('login_history.html', history=history)


#---- eidt and delete buttion in view patiets
@app.route('/edit_patient/<string:patient_id>', methods=['GET', 'POST'])
def edit_patient(patient_id):

    if 'user_id' not in session:
        return redirect(url_for('home'))

    conn = get_connection()
    cursor = conn.cursor()

    if request.method == 'POST':
        name = request.form['name']
        age = request.form['age']
        gender = request.form['gender']
        phone = request.form['phone']
        address = request.form['address']

        # Call your Upsert SP
        cursor.execute("""
            EXEC dbo.Hos_Patients_Upsert
                @PatientID=?,
                @FullName=?,
                @Age=?,
                @Gender=?,
                @Phone=?,
                @Address=?,
                @IsActive=?,
                @IsDeleted=?,
                @CreatedDateTime=?,
                @UpdatedDateTime=?,
                @UpdatedBy=?,
                @UserProfile=?
        """, (
            patient_id,
            name,
            age,
            gender,
            phone,
            address,
            1,                      # IsActive
            0,                      # IsDeleted
            None,                   # CreatedDateTime (SP handles default)
            None,                   # UpdatedDateTime
            session.get('full_name', 'Admin'),  # UpdatedBy
            'WebApp - Edit Patient'             # UserProfile
        ))

        conn.commit()
        conn.close()

        return redirect(url_for('view_patients'))

    # GET request - fetch patient
    cursor.execute("SELECT * FROM Patients WHERE PatientID=?", (patient_id,))
    patient = cursor.fetchone()
    conn.close()

    return render_template('edit_patient.html', patient=patient)

#-- delete patient route added in soft delete code, so no need here--



# ----------------------------
# DASHBOARD (Protected)
# ----------------------------
@app.route('/dashboard')
def dashboard():

    if 'user_id' not in session:
        return redirect(url_for('home'))

    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("EXEC dbo.Hos_Patients_Count")

    row = cursor.fetchone()
    total_patients = row[0] if row else 0

    conn.close()

    return render_template(
        'index.html',
        name=session['full_name'],
        total_patients=total_patients
    )


# =========================
# BOOK APPOINTMENT (Protected)
# =========================
@app.route('/book_appointment', methods=['GET', 'POST'])
def book_appointment():
    if 'user_id' not in session:
        return redirect(url_for('home'))

    conn = get_connection()
    cursor = conn.cursor()

    # Load patients & doctors for dropdown
    cursor.execute("SELECT PatientID, FullName FROM Patients WHERE IsActive=1 AND IsDeleted=0")
    patients = cursor.fetchall()

    cursor.execute("SELECT DoctorID, FullName FROM Doctors WHERE IsActive=1 AND IsDeleted=0")
    doctors = cursor.fetchall()

    if request.method == 'POST':
        appointment_id = str(uuid.uuid4())
        patient_id = request.form['patient_id']
        doctor_id = request.form['doctor_id']
        appointment_date = request.form['appointment_date']
        reason = request.form['reason']

        cursor.execute("""
            INSERT INTO Appointments
            (AppointmentID, PatientID, DoctorID, AppointmentDate, Reason, IsActive, IsDeleted)
            VALUES (?, ?, ?, ?, ?, 1, 0)
        """, (appointment_id, patient_id, doctor_id, appointment_date, reason))

        conn.commit()
        conn.close()

        return redirect(url_for('view_appointments'))

    conn.close()
    return render_template('book_appointment.html', patients=patients, doctors=doctors)

# =========================
# VIEW APPOINTMENTS
# =========================
@app.route('/view_appointments')
def view_appointments():
    if 'user_id' not in session:
        return redirect(url_for('home'))

    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("""
        SELECT A.AppointmentID,
               P.FullName AS PatientName,
               D.FullName AS DoctorName,
               A.AppointmentDate,
               A.Reason
        FROM Appointments A
        JOIN Patients P ON A.PatientID = P.PatientID
        JOIN Doctors D ON A.DoctorID = D.DoctorID
        WHERE A.IsActive = 1 AND A.IsDeleted = 0
        ORDER BY A.AppointmentDate DESC
    """)

    appointments = cursor.fetchall()
    conn.close()

    return render_template('view_appointments.html', appointments=appointments)

# =========================
# ADD PATIENT (Protected)
# =========================
@app.route('/add_patient', methods=['GET', 'POST'])
def add_patient():
    if 'user_id' not in session:
        return redirect(url_for('home'))

    if request.method == 'POST':
        name = request.form['name']
        age = request.form['age']
        gender = request.form['gender']
        phone = request.form['phone']
        address = request.form['address']

        conn = get_connection()
        cursor = conn.cursor()

        cursor.execute("""
            INSERT INTO Patients 
            (PatientID, FullName, Age, Gender, Phone, Address, IsActive, IsDeleted)
            VALUES (?, ?, ?, ?, ?, ?, 1, 0)
        """, (str(uuid.uuid4()), name, age, gender, phone, address))

        conn.commit()
        conn.close()

        return redirect(url_for('view_patients'))

    return render_template('add_patient.html')

# =========================
# VIEW PATIENTS (Protected)
# =========================
@app.route('/view_patients')
def view_patients():
    if 'user_id' not in session:
        return redirect(url_for('home'))

    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("""
        SELECT *
        FROM Patients
        WHERE IsDeleted = 0 AND IsActive = 1
        ORDER BY CreatedDateTime DESC
    """)

    patients = cursor.fetchall()
    conn.close()

    return render_template('view_patients.html', patients=patients)

# =========================
# DELETE PATIENT (Soft Delete)
# =========================
@app.route('/delete_patient/<string:patient_id>')
def delete_patient(patient_id):
    if 'user_id' not in session:
        return redirect(url_for('home'))

    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("""
        UPDATE Patients
        SET IsDeleted = 1,
            IsActive = 0
        WHERE PatientID = ?
    """, (patient_id,))

    conn.commit()
    conn.close()

    return redirect(url_for('view_patients'))

# =========================
# ADD DOCTOR (Protected)
# =========================
@app.route('/add_doctor', methods=['GET', 'POST'])
def add_doctor():
    if 'user_id' not in session:
        return redirect(url_for('home'))

    if request.method == 'POST':
        name = request.form['name']
        specialty = request.form['specialty']

        conn = get_connection()
        cursor = conn.cursor()

        cursor.execute("""
            INSERT INTO Doctors
            (DoctorID, FullName, Specialty, IsActive, IsDeleted)
            VALUES (?, ?, ?, 1, 0)
        """, (str(uuid.uuid4()), name, specialty))

        conn.commit()
        conn.close()

        return redirect(url_for('dashboard'))

    return render_template('add_doctor.html')

# ----------------------------
# LOGOUT
# ----------------------------
@app.route('/logout')
def logout():
    session.clear()
    return redirect(url_for('home'))

# ----------------------------
if __name__ == "__main__":
    app.run(debug=True)