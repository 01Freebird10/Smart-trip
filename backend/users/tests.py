from django.test import TestCase


class UserModelTest(TestCase):
    """Basic tests for the User model."""
    
    def test_basic_sanity(self):
        """Test that basic assertions work - placeholder for CI/CD."""
        self.assertEqual(1 + 1, 2)
    
    def test_string_operations(self):
        """Test basic string operations."""
        self.assertEqual("hello".upper(), "HELLO")
