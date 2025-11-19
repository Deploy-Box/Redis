// Connect through nginx proxy (same origin)
const socket = io({
    path: '/socket.io/',
    transports: ['polling', 'websocket'],
    reconnection: true,
    reconnectionDelay: 1000,
    reconnectionAttempts: 10
});

const chatWindow = document.getElementById('chat-window');
const chatForm = document.getElementById('chat-form');
const chatInput = document.getElementById('chat-input');
const connectionStatus = document.getElementById('connection-status');

function appendMessage(msg) {
    const div = document.createElement('div');
    div.textContent = msg;
    chatWindow.appendChild(div);
    chatWindow.scrollTop = chatWindow.scrollHeight;
}

// Update connection status
socket.on('connect', function() {
    connectionStatus.textContent = 'Connected';
    connectionStatus.style.color = 'green';
    appendMessage('System: Connected to server');
});

socket.on('connect_error', function(error) {
    connectionStatus.textContent = 'Connection error:';
    connectionStatus.style.color = 'red';
    appendMessage('System: Connection error:' + error);
});

socket.on('disconnect', function(reason) {
    connectionStatus.textContent = 'Disconnected';
    connectionStatus.style.color = 'red';
    appendMessage('System: Disconnected from server');
});

chatForm.addEventListener('submit', function(e) {
    e.preventDefault();
    const msg = chatInput.value.trim();
    if (msg) {
        socket.emit('message', { message: msg });
        appendMessage('You: ' + msg);
        chatInput.value = '';
    }
});

// Listen for incoming messages from backend
socket.on('response', function(msg) {
    console.log('Received message from backend:', msg);
    if (msg.message) {
        appendMessage('Server: ' + msg.message);
    }
});

// Listen for server updates
socket.on('server_update', function(data) {
    console.log('Server update:', data);
    appendMessage('Server: ' + data.message);
});