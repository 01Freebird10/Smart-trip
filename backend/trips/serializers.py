from rest_framework import serializers
from .models import Trip, Collaborator, ItineraryItem, Poll, PollOption, Vote, Expense, Booking
from users.serializers import UserSerializer

class BookingSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    class Meta:
        model = Booking
        fields = ('id', 'user', 'trip', 'destination', 'adults', 'children', 'total_amount', 'status', 'created_at')
        read_only_fields = ('user', 'status')

class CollaboratorSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    user_email = serializers.EmailField(write_only=True)

    class Meta:
        model = Collaborator
        fields = ('id', 'user', 'user_email', 'role', 'joined_at')

class ItineraryItemSerializer(serializers.ModelSerializer):
    class Meta:
        model = ItineraryItem
        fields = '__all__'

class ExpenseSerializer(serializers.ModelSerializer):
    class Meta:
        model = Expense
        fields = '__all__'

class PollOptionSerializer(serializers.ModelSerializer):
    vote_count = serializers.IntegerField(source='votes.count', read_only=True)
    has_voted = serializers.SerializerMethodField()

    class Meta:
        model = PollOption
        fields = ('id', 'text', 'vote_count', 'has_voted')

    def get_has_voted(self, obj):
        user = self.context['request'].user
        return obj.votes.filter(user=user).exists()

class PollSerializer(serializers.ModelSerializer):
    options = PollOptionSerializer(many=True, read_only=True)
    option_texts = serializers.ListField(child=serializers.CharField(), write_only=True, required=False)
    created_by = UserSerializer(read_only=True)

    class Meta:
        model = Poll
        fields = ('id', 'question', 'created_by', 'created_at', 'is_active', 'options', 'option_texts')

    def create(self, validated_data):
        option_texts = validated_data.pop('option_texts', [])
        poll = Poll.objects.create(**validated_data)
        for text in option_texts:
            PollOption.objects.create(poll=poll, text=text)
        return poll

class TripSerializer(serializers.ModelSerializer):
    owner = UserSerializer(read_only=True)
    collaborators = CollaboratorSerializer(many=True, read_only=True)
    bookings = BookingSerializer(many=True, read_only=True)
    image = serializers.ImageField(required=False, allow_null=True)
    
    class Meta:
        model = Trip
        fields = ('id', 'title', 'description', 'destination', 'start_date', 'end_date', 'owner', 'collaborators', 'image', 'budget', 'created_at', 'bookings')
        read_only_fields = ('owner',)
