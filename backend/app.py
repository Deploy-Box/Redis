import eventlet
eventlet.monkey_patch()  # must come first!

from flask import Flask, render_template
from flask_socketio import SocketIO, emit
import time
import os

# Flask setup
app = Flask(__name__)
app.config['SECRET_KEY'] = 'supersecret'

# Redis + eventlet setup
socketio = SocketIO(app, message_queue='redis://127.0.0.1:6379', cors_allowed_origins="*")

app.static_folder = os.path.join(os.path.dirname(os.path.abspath(__file__)), '../frontend')

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/<path:path>')
def static_files(path):
    return render_template(path)

# --- Handle incoming messages ---
@socketio.on('message')
def handle_message(data):
    print(f"Received message from client: {data}")
    emit('response', data, broadcast=True)

# --- Example of a named custom event ---
@socketio.on('custom_event')
def handle_custom_event(data):
    print(f"Custom event triggered: {data}")
    emit('custom_response', {'message': f'Got your event: {data}'}, broadcast=True)

# --- Background task emitting periodically ---
def background_emitter():
    """Server-side background emit every 5 seconds."""
    while True:
        socketio.emit('server_update', {'message': f'Server time: {time.strftime("%H:%M:%S")}'})
        time.sleep(5)

# Launch background thread on startup
@socketio.on('connect')
def on_connect():
    print("Client connected")
    emit('response', {'message': 'Welcome!'})
    # Start background emitter once
    socketio.start_background_task(target=background_emitter)

if __name__ == '__main__':
    print("Starting Flask-SocketIO app with Redis backend and emit logic...")
    socketio.run(app, host='0.0.0.0', port=5000)
