import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class ApiKeyDialog extends StatefulWidget {
  final String? initialValue;
  final Function(String) onApiKeySaved;

  const ApiKeyDialog({Key? key, this.initialValue, required this.onApiKeySaved}) : super(key: key);

  @override
  State<ApiKeyDialog> createState() => _ApiKeyDialogState();
}

class _ApiKeyDialogState extends State<ApiKeyDialog> {
  final TextEditingController _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      _controller.text = widget.initialValue!;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _launchOpenAIWebsite() async {
    const url = 'https://platform.openai.com/api-keys';
    try {
      await launchUrl(Uri.parse(url));
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('URL açılamadı: $url')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('OpenAI API Anahtarını Girin'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'AI analizi için OpenAI API anahtarınızı girin. API anahtarınız yoksa, aşağıdaki bağlantıdan ücretsiz olarak alabilirsiniz.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _launchOpenAIWebsite,
              child: const Text(
                'OpenAI API Anahtarı Al',
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'API Anahtarı',
                hintText: 'sk-...',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                ),
              ),
              obscureText: _obscureText,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Lütfen API anahtarını girin';
                }
                if (!value.startsWith('sk-')) {
                  return 'Geçerli bir OpenAI API anahtarı girin (sk- ile başlar)';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onApiKeySaved(_controller.text);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Kaydet'),
        ),
      ],
    );
  }
}
