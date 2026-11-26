# ذكي - ألعاب ذكاء للأطفال (٦ سنين)

مشروع Flutter للأندرويد. الألعاب: بازل، تلوين، كتابة (تتبّع الحروف)، قراءة، كوّن الكلمة،
فك وتركيب، الذاكرة، كمّل النمط. الحروف والكلمات عربي وإنجليزي، والصوت مؤثرات بس.

## البناء
- GitHub Actions (ملف `.github/workflows/build-apk.yml`) بيبني الـ APK ويرفعه في Artifacts باسم `zaki-apk`.
- أو محلياً: `flutter create --platforms=android .` ثم `flutter pub get` ثم `dart run flutter_launcher_icons` ثم `flutter build apk --release`.

## الملفات
- `lib/core.dart`: النجوم والصوت وإطار الألعاب وشاشة التهنئة.
- `lib/data.dart`: الكلمات والحروف (تقدر تزوّد كلمات من هنا).
- `lib/games/*.dart`: كل لعبة في ملف.
- `assets/sounds/`: المؤثرات الصوتية.
