from django.core.management.utils import get_random_secret_key

secretKey = 'SECURITY_KEY='
key = get_random_secret_key()

print(secretKey + '"' + str(key) + '"')
