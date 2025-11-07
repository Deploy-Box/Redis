// Connect to backend Socket.IO server
const socket = io('/api/', { transports: ['polling'] });

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
});

socket.on('disconnect', function() {
    connectionStatus.textContent = 'Disconnected';
    connectionStatus.style.color = 'red';
});

chatForm.addEventListener('submit', function(e) {
    e.preventDefault();
    const msg = chatInput.value.trim();
    if (msg) {
        socket.emit('message', { message: msg });
        chatInput.value = '';
    }
});

// Listen for incoming messages from backend
socket.on('response', function(msg) {
    console.log('Received message from backend:', msg.message);
    appendMessage('Friend: ' + msg.message);
});
