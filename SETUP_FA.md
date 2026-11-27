# انتشار نسخهٔ وب (PWA) — صندوق شارژ ساختمان

اپ حالا یک وب‌اپ است؛ بدون گوگل‌پلی. کاربران آدرس سایت را باز می‌کنند و از منوی مرورگر «افزودن به صفحهٔ اصلی» را می‌زنند تا مثل اپ نصب شود.

## ساخت (دو راه)
**الف) لوکال:** `flutter pub get && flutter test && flutter build web --release --no-web-resources-cdn --pwa-strategy=offline-first`
خروجی در `build/web` است. گزینهٔ `--no-web-resources-cdn` مهم است: CanvasKit را داخل خروجی می‌گذارد تا به gstatic.com (مسدود در ایران) وابسته نباشد.

**ب) بدون نصب Flutter:** پروژه را در یک ریپوی GitHub بگذارید، در Settings → Secrets دو مقدار `SUPABASE_URL` و `SUPABASE_ANON_KEY` را بسازید و workflow به نام build-web را اجرا کنید. خروجی را از Artifacts دانلود کنید.

## میزبانی
محتوای `build/web` را روی هر هاست استاتیک آپلود کنید (سرور خودتان با nginx، لیارا، آروان‌کلود، ...). نمونهٔ تنظیم nginx در `web/nginx.conf.example` است. حتماً HTTPS فعال باشد (برای PWA لازم است) و همهٔ مسیرها به index.html برگردند.

## نکات
- فایل `.env` در خروجی وب قابل دیدن است؛ فقط کلید anon (عمومی) باید در آن باشد و RLS در Supabase فعال بماند. service_role را هرگز آنجا نگذارید.
- Realtime: جدول‌های charge_payments, expenses, goals, apartments باید در publication `supabase_realtime` باشند.
- پیوست‌ها: باکت `expense-files`، مسیر `expenses/{expenseId}/{file}`؛ فقط مدیر مجوز نوشتن دارد.
- خروجی PDF/Excel در وب دانلود مرورگر می‌شود.
- اگر Supabase ابری از داخل ایران پایدار نبود، بک‌اند قابل جایگزینی است (لایهٔ datasource مجزاست).
