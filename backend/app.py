import eventlet
eventlet.monkey_patch()  # must come first!

from flask import Flask, render_template, Response
from flask_socketio import SocketIO, emit
import time
import os

# Flask setup
app = Flask(__name__)
app.config['SECRET_KEY'] = 'supersecret'

# Redis + eventlet setup
socketio = SocketIO(app, 
                   cors_allowed_origins="*",
                   async_mode='threading',
                   logger=True,
                   engineio_logger=True,
                   ping_timeout=60,
                   ping_interval=25)

app.static_folder = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'frontend')

@app.route('/')
def index():
    return "Hello World!"

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

# Move background task outside connect handler
background_task_started = False

@socketio.on('connect')
def on_connect():
    global background_task_started
    print("Client connected")
    emit('response', {'message': 'Welcome!'})
    # Start background emitter only once
    if not background_task_started:
        background_task_started = True
        socketio.start_background_task(target=background_emitter)

if __name__ == '__main__':
    print("Starting Flask-SocketIO app with Redis backend and emit logic...")
    socketio.run(app, host='0.0.0.0', port=5000)
