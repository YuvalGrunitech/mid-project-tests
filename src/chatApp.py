from flask import Flask, render_template, request, redirect, url_for,session
from flask_session import Session
import pandas as pd
import base64
import os
import datetime
global rooms_path



# Get the value of the environment variable 'rooms_path'
rooms_path = os.environ.get('ROOMS_PATH')
users_path = os.environ.get('USERS_PATH')


app = Flask(__name__)

# Configure the app to use sessions
app.config['SESSION_TYPE'] = 'filesystem'
Session(app)

@app.route("/", methods=["GET", "POST"])
@app.route("/register", methods=["GET", "POST"])
def homePage():
    if request.method == "GET":
        return render_template("register.html")
    


    if request.method == "POST":
        # Load the CSV file as a DataFrame
        users_df = pd.read_csv(users_path)
        # Get user input from the form
        username = request.form.get("username")
        password = request.form.get("password")

        # Encode the password in Base64
        encoded_password = base64.b64encode(password.encode()).decode()

        # Check if the user already exists in the DataFrame
        if username in users_df['username'].values:
            return "Username already exists! Please choose a different username."

        if username == "Guest":
            return "Username cannot be Guest, Guest is defined for guest users. Choose another username"
        
        # Add the new user to the DataFrame
        new_user = {'username': username, 'password': encoded_password}
        users_df = users_df.append(new_user, ignore_index=True)

        # Save the updated DataFrame to the CSV file
        users_df.to_csv(users_path, index=False)
        

        return redirect(url_for("loginPage"))


@app.route("/login", methods=["GET", "POST"])
def loginPage():
    if request.method == "GET":
        return render_template("login.html")
    


    if request.method == "POST":

        # Load the CSV file as a DataFrame
        users_df = pd.read_csv(users_path)

        # Get user input from the form
        username = request.form.get("username")
        password = request.form.get("password")

        
        # Extract username and password from the DataFrame
        user_data = users_df[users_df['username'] == username]
        
        if user_data.empty:
            return "Invalid username. Please try again."

        stored_encoded_password = user_data.iloc[0]['password']

        # Decode the stored Base64-encoded password
        stored_password = base64.b64decode(stored_encoded_password.encode()).decode('utf-8')

        

        # Compare the decoded password with the provided password
        if password == stored_password and username == user_data.iloc[0]['username']:
            # Creating a new session
            session['username'] = username

            return redirect(url_for("lobbyPage"))
        else:
            return "Invalid password. Please try again."


def getRoomNames():
    # Get a list of all items (files and directories) in the folder
    all_items = os.listdir(rooms_path)

    # Filter the list to include only files (not directories)
    room_names = [item.strip(".txt") for item in all_items if os.path.isfile(os.path.join(rooms_path, item))]
    
    return room_names



@app.route("/lobby", methods=["GET", "POST"])
def lobbyPage():
    # Get room names
    room_names = getRoomNames()

    if request.method == "GET":
        return render_template('lobby.html', room_names=room_names)
    
    if request.method == "POST":
        if request.form.get('Create'):
            # Getting new room from user
            new_room = request.form.get("new_room")

            # Create the full file path by joining the folder path and file name
            file_path = os.path.join(rooms_path, f"{new_room}.txt")
            
            # Checking if room already exists
            if os.path.isfile(file_path):
                return "Invalid Input, room already exists!" 
            
            # Creating a new file for room messages
            open(file_path, 'w').close()

            # Updating room names
            room_names = getRoomNames()

            return render_template('lobby.html', room_names=room_names)

        
        


@app.route("/chat/<room>")
def chatRoom(room):
    return render_template("chat.html",room=room)


@app.route("/api/chat/<room>",methods=["GET","POST"])
def getChat(room):
    data = ''
    user = session['username']
    # Create the full file path by joining the folder path and file name
    file_path = os.path.join(rooms_path, f"{room}.txt")

    if request.method == "POST":
        # Clear feature added with bug
        # if request.args.get('clear') == "true":
        #     with open(file_path,'r+') as f:
        #         f.truncate(0)

        # Clear feature fixed
        if request.args.get('clear') == "true":
            with open(file_path,'r') as f:
                lines = f.readlines()
            with open(file_path,'w') as f:
                for line in lines:
                    if f"{session['username']}:" != line.split(" ")[2]:
                        f.write(line)
        
        else:
            msg = request.form["msg"]
            timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            fullmsg = f'[{timestamp}] {user}: {msg}\n'
            with open(file_path,'a+') as file: 
                file.write(f'{fullmsg}')
        
        
        
        return render_template("chat.html", room=room)
    

    elif request.method == "GET":
        with open(file_path, 'r') as file:
                data = file.read()
        return data
    

@app.route('/logout')
def logout():
  # Remove the username from the session
  session.pop('username', None)
  return redirect(url_for("loginPage"))


@app.route('/health')
def healthcheck():
    return "OK", 200

if __name__ == "__main__":
    # Check if the folder path exists
    if not os.path.exists(rooms_path):
        print("Error, rooms path do not exist!")
    app.run(debug=True,host="0.0.0.0")
    