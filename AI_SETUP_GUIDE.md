# ChatGPT AI Setup Guide

This guide will help you set up the ChatGPT-powered AI assistant in your ConnectSphere app.

## Step 1: Get Your OpenAI API Key

1. Visit [OpenAI Platform](https://platform.openai.com/api-keys)
2. Sign up or log in to your OpenAI account
3. Click on your profile icon → "API keys"
4. Click "Create new secret key"
5. Copy the generated API key (it starts with `sk-`)
6. ⚠️ **Important**: Save this key somewhere secure. Never commit it to version control!

## Step 2: Add API Key to Your App

### Method 1: Environment Variable (Recommended for Development)

Edit `lib/main.dart` and find the `AIChatScreen` class around line 3760:

```dart
class _AIChatScreenState extends State<AIChatScreen> {
  final List<ChatMessage> messages = [];
  final TextEditingController _msgCtrl = TextEditingController();
  bool _isLoading = false;
  
  // Replace 'sk-your-api-key-here' with your actual API key
  static const String OPENAI_API_KEY = 'sk-your-actual-api-key-here';
  static const String OPENAI_API_URL = 'https://api.openai.com/v1/chat/completions';
```

Replace `'sk-your-api-key-here'` with your actual API key.

### Method 2: Use Environment Configuration (Better for Production)

Create a new file `lib/config.dart`:

```dart
// lib/config.dart
const String OPENAI_API_KEY = String.fromEnvironment(
  'OPENAI_API_KEY',
  defaultValue: 'sk-your-default-key',
);
```

Then update `lib/main.dart`:
```dart
import 'config.dart';

class _AIChatScreenState extends State<AIChatScreen> {
  static const String OPENAI_API_KEY = OPENAI_API_KEY;
  // ... rest of code
}
```

## Step 3: Test the AI Chat

1. Run your app: `flutter run`
2. Tap the AI bot icon in the header
3. Start chatting! The bot will maintain conversation context

## Features

✅ **ChatGPT-Like Responses** - Uses OpenAI's gpt-3.5-turbo model
✅ **Conversation Context** - Maintains last 5 messages for intelligent responses
✅ **Error Handling** - Shows helpful error messages if API key is invalid
✅ **Rate Limiting** - Handles API rate limits gracefully
✅ **Typing Indicator** - Shows when AI is thinking

## Supported Models

- `gpt-3.5-turbo` - Fast, cost-effective (current)
- `gpt-4` - More powerful but more expensive
- `gpt-4-turbo` - Latest and most capable

To change the model, edit line in `_getAIResponse()`:
```dart
'model': 'gpt-4', // Change here
```

## Cost Considerations

OpenAI charges per API call:
- **gpt-3.5-turbo**: ~$0.0005 per message (very cheap)
- **gpt-4**: ~$0.03 per message (more expensive)

Check your usage at: https://platform.openai.com/account/usage/overview

Set spending limits to avoid unexpected charges:
1. Go to [Billing Overview](https://platform.openai.com/account/billing/overview)
2. Set a "Monthly budget"

## Troubleshooting

### "Please set your OpenAI API key in the code"
- Your API key is still set to the default
- Replace `'sk-your-api-key-here'` with your actual key

### "Invalid API key"
- Check that you copied the full key correctly
- Make sure there are no extra spaces
- Verify the key starts with `sk-`

### "Rate limit exceeded"
- You've hit OpenAI's rate limit
- Wait a moment before sending more messages
- Consider upgrading your OpenAI account

### Connection timeout
- Check your internet connection
- Make sure OpenAI's API is accessible in your region
- Try with a shorter timeout: edit the Duration(seconds: 30)

## Security Best Practices

🔒 **Never:**
- Commit your API key to GitHub
- Share your API key publicly
- Use production API keys in client apps

✅ **Do:**
- Use environment variables
- Rotate keys regularly
- Monitor API usage
- Use a backend proxy for production apps

## Additional Resources

- [OpenAI API Documentation](https://platform.openai.com/docs/api-reference)
- [Chat Completions Guide](https://platform.openai.com/docs/guides/gpt)
- [OpenAI Pricing](https://openai.com/pricing)
- [Rate Limits Documentation](https://platform.openai.com/docs/guides/rate-limits)

## Next Steps

1. ✅ Get your API key
2. ✅ Add it to the code
3. ✅ Test the chat
4. 📊 Monitor your API usage
5. 🚀 Deploy with proper security measures

Happy chatting! 🤖
