import os
from flask import Flask, request, redirect, session
import requests
from urllib.parse import urlencode


app = Flask(__name__)
app.secret_key = os.environ.get("SECRET_KEY")

OKTA_ISSUER = os.environ.get("OKTA_ISSUER")
OKTA_CLIENT_ID = os.environ.get("OKTA_CLIENT_ID")
OKTA_CLIENT_SECRET = os.environ.get("OKTA_CLIENT_SECRET")
REDIRECT_URI = os.environ.get("REDIRECT_URI")


@app.route("/")
def index():
    user = session.get("user")
    if user:
        return f"""
                <h1>✅ Login Success!</h1>
                <p><strong>Name:</strong> {user.get('name', 'Unknown')}</p>
                <p><strong>Email:</strong> {user.get('email', 'Unknown')}</p>
                <p><a href="/logout">Logout</a></p>
                """
    else:
        return '''
                <h1> vinted Test App</h1>
                <p><a href="/login">Login with Okta</a></p>
                '''

@app.route("/login")
def login():
    auth_url = f"{OKTA_ISSUER}/v1/authorize?" + urlencode({
        'client_id': OKTA_CLIENT_ID,
        'response_type': 'code',
        'scope': 'openid email profile',
        'redirect_uri': REDIRECT_URI,
        'state': 'test'
    })
    return redirect(auth_url)


@app.route('/auth/callback')
def callback():
    code = request.args.get('code')
    if not code:
        return "havent received the code "

    token_response = requests.post(f"{OKTA_ISSUER}/v1/token", data={
        'grant_type': 'authorization_code',
        'client_id': OKTA_CLIENT_ID,
        'client_secret': OKTA_CLIENT_SECRET,
        'code': code,
        'redirect_uri': REDIRECT_URI
    })

    tokens = token_response.json()
    if 'access_token' not in tokens:
        return f"❌ Token error: {tokens}"

    # Get user info
    user_response = requests.get(f"{OKTA_ISSUER}/v1/userinfo",
                                 headers={'Authorization': f"Bearer {tokens['access_token']}"})

    session['user'] = user_response.json()
    return redirect('/')


@app.route('/logout')
def logout():
    session.clear()
    return redirect('/')

@app.route('/health')
def health():
    return {'status': 'ok'}

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 8080))
    app.run(host='0.0.0.0', port=port)