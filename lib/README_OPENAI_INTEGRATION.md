# OpenAI API Entegrasyonu - Kullanım Kılavuzu

## Genel Bakış

Bu entegrasyon, Akıllı Doktor Asistanı uygulamasında hasta analizleri için OpenAI GPT-3.5 modelini kullanmanızı sağlar. Gemini API'de yaşanan sorunlar nedeniyle alternatif bir çözüm olarak eklenmiştir.

## Dosyalar

Aşağıdaki dosyalar, OpenAI API entegrasyonu için oluşturulmuştur:

1. `lib/services/openai_api_service.dart` - OpenAI API ile iletişim kuran servis sınıfı
2. `lib/widgets/openai_api_key_dialog.dart` - API anahtarını girmek için dialog widget'ı
3. `lib/screens/ai_analiz_raporu_page_openai.dart` - OpenAI API kullanan analiz raporu sayfası
4. `lib/screens/ai_analysis_screen_openai_ready.dart` - OpenAI API kullanan AI analiz ekranı

## Kullanım

OpenAI API entegrasyonunu kullanmak için iki seçeneğiniz var:

### 1. Seçenek: Mevcut Uygulamayı Değiştirmeden Kullanma

Bu seçenek, mevcut uygulamanızı değiştirmeden OpenAI API'yi kullanmanızı sağlar:

1. Uygulamanızı normal şekilde çalıştırın
2. "AI Analizi Başlat" butonuna tıklayın
3. Açılan dialog'a OpenAI API anahtarınızı girin:
   ```
   ***REMOVED***
   ```
4. Analiz otomatik olarak başlayacaktır

### 2. Seçenek: Uygulamayı OpenAI API Kullanacak Şekilde Güncelleme

Bu seçenek, uygulamanızı tamamen OpenAI API kullanacak şekilde günceller:

1. `lib/screens/ai_analysis_screen.dart` dosyasını `lib/screens/ai_analysis_screen_openai_ready.dart` ile değiştirin
2. `lib/screens/ai_analiz_raporu_page.dart` dosyasını `lib/screens/ai_analiz_raporu_page_openai.dart` ile değiştirin
3. Uygulamanızı yeniden başlatın

## API Anahtarı Hakkında

- OpenAI API anahtarınız, uygulamanızda güvenli bir şekilde saklanır
- Ücretsiz deneme kredisi ile yüzlerce hasta analizi yapabilirsiniz
- Krediniz bittiğinde, yeni bir API anahtarı almanız gerekebilir

## Sorun Giderme

Eğer API ile ilgili sorunlar yaşarsanız:

1. API anahtarınızın doğru olduğundan emin olun
2. OpenAI hesabınızda kredinizin olup olmadığını kontrol edin
3. Uygulamayı yeniden başlatın ve API anahtarını tekrar girin

## Geri Dönüş

Eğer Gemini API'ye geri dönmek isterseniz, orijinal dosyaları kullanmaya devam edebilirsiniz. Tüm orijinal dosyalar korunmuştur.
