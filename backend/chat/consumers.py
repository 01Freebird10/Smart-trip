import json
from channels.generic.websocket import AsyncWebsocketConsumer
from channels.db import database_sync_to_async
from .models import Message
from trips.models import Trip

class ChatConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        self.trip_id = self.scope['url_route']['kwargs']['trip_id']
        self.room_group_name = f'chat_{self.trip_id}'

        # Join room group
        await self.channel_layer.group_add(
            self.room_group_name,
            self.channel_name
        )

        await self.accept()

        # Send chat history
        history = await self.get_history()
        for msg in history:
            await self.send(text_data=json.dumps(msg))

    async def disconnect(self, close_code):
        # Leave room group
        await self.channel_layer.group_discard(
            self.room_group_name,
            self.channel_name
        )

    # Receive message from WebSocket
    async def receive(self, text_data):
        text_data_json = json.loads(text_data)
        message = text_data_json['message']
        user = self.scope['user']

        if user.is_authenticated:
            # Save message to database
            await self.save_message(user, message)

            # Send message to room group
            await self.channel_layer.group_send(
                self.room_group_name,
                {
                    'type': 'chat_message',
                    'message': message,
                    'user': user.email,
                    'timestamp': 'now'
                }
            )

    # Receive message from room group
    async def chat_message(self, event):
        message = event['message']
        user = event['user']

        # Send message to WebSocket
        await self.send(text_data=json.dumps({
            'message': message,
            'user': user
        }))

    @database_sync_to_async
    def save_message(self, user, content):
        trip = Trip.objects.get(id=self.trip_id)
        return Message.objects.create(trip=trip, user=user, content=content)

    @database_sync_to_async
    def get_history(self):
        messages = Message.objects.filter(trip_id=self.trip_id).order_by('timestamp')[:50]
        return [{
            'message': m.content,
            'user': m.user.email,
            'timestamp': m.timestamp.isoformat()
        } for m in messages]
