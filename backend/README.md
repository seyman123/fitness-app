# Fitness App Backend API

Node.js + Express + Prisma + SQLite ile geliştirilmiş fitness uygulaması backend API'si.

## Kurulum

```bash
# Bağımlılıkları yükle
npm install

# Veritabanını oluştur ve migrate et
npm run db:migrate

# Geliştirme modunda çalıştır (hot reload)
npm run dev

# Production modunda çalıştır
npm start
```

## Çevre Değişkenleri

`.env` dosyası oluşturun ve aşağıdaki değişkenleri ekleyin:

```env
DATABASE_URL="file:./dev.db"
JWT_SECRET="your-secret-key-here"
JWT_EXPIRES_IN="7d"
PORT=3000
NODE_ENV="development"
```

## API Endpoints

### Authentication

#### Kayıt Ol
```http
POST /api/auth/register
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "123456",
  "name": "İsim Soyisim"
}
```

**Yanıt:**
```json
{
  "message": "Kayıt başarılı",
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "name": "İsim Soyisim",
    "createdAt": "2024-11-24T..."
  },
  "token": "jwt-token"
}
```

#### Giriş Yap
```http
POST /api/auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "123456"
}
```

**Yanıt:**
```json
{
  "message": "Giriş başarılı",
  "user": { ... },
  "token": "jwt-token"
}
```

#### Kullanıcı Bilgilerini Al
```http
GET /api/auth/me
Authorization: Bearer {token}
```

### Profile

#### Profil Oluştur/Güncelle
```http
POST /api/profile
PUT /api/profile
Authorization: Bearer {token}
Content-Type: application/json

{
  "age": 25,
  "gender": "male",
  "height": 175,
  "weight": 70,
  "goalWeight": 65,
  "activityLevel": 1.5
}
```

**Yanıt:**
```json
{
  "profile": {
    "id": "uuid",
    "userId": "uuid",
    "age": 25,
    "gender": "male",
    "height": 175,
    "weight": 70,
    "goalWeight": 65,
    "activityLevel": 1.5,
    "createdAt": "...",
    "updatedAt": "..."
  },
  "calculations": {
    "bmi": 22.9,
    "bmiCategory": "Normal",
    "dailyCalories": 2100
  }
}
```

#### Profil Bilgilerini Al
```http
GET /api/profile
Authorization: Bearer {token}
```

### Water Tracking

#### Su Tüketimi Ekle
```http
POST /api/water
Authorization: Bearer {token}
Content-Type: application/json

{
  "amount": 250,
  "date": "2024-11-24T10:30:00Z"
}
```

#### Tüm Su Kayıtlarını Al
```http
GET /api/water?startDate=2024-11-01&endDate=2024-11-24
Authorization: Bearer {token}
```

#### Bugünün Su Tüketimini Al
```http
GET /api/water/today
Authorization: Bearer {token}
```

**Yanıt:**
```json
{
  "entries": [
    {
      "id": "uuid",
      "userId": "uuid",
      "amount": 250,
      "date": "2024-11-24T10:30:00Z",
      "createdAt": "..."
    }
  ],
  "total": 1500,
  "count": 6
}
```

#### Su Kaydını Sil
```http
DELETE /api/water/{id}
Authorization: Bearer {token}
```

### Nutrition Tracking

#### Beslenme Kaydı Ekle
```http
POST /api/nutrition
Authorization: Bearer {token}
Content-Type: application/json

{
  "mealType": "breakfast",
  "foodName": "Yumurta",
  "calories": 150,
  "protein": 12,
  "carbs": 2,
  "fat": 10,
  "date": "2024-11-24T08:00:00Z"
}
```

**Meal Types:** `breakfast`, `lunch`, `dinner`, `snack`

#### Tüm Beslenme Kayıtlarını Al
```http
GET /api/nutrition?startDate=2024-11-01&endDate=2024-11-24&mealType=breakfast
Authorization: Bearer {token}
```

#### Bugünün Beslenme Kayıtlarını Al
```http
GET /api/nutrition/today
Authorization: Bearer {token}
```

**Yanıt:**
```json
{
  "logs": [...],
  "totals": {
    "calories": 1800,
    "protein": 120,
    "carbs": 180,
    "fat": 60
  },
  "byMealType": {
    "breakfast": [...],
    "lunch": [...],
    "dinner": [...],
    "snack": [...]
  },
  "count": 8
}
```

#### Beslenme Kaydını Sil
```http
DELETE /api/nutrition/{id}
Authorization: Bearer {token}
```

## Veritabanı

### Prisma Studio ile Veritabanını İncele
```bash
npm run db:studio
```

### Veritabanı Şeması

- **User**: Kullanıcı bilgileri
- **UserProfile**: Profil detayları (yaş, boy, kilo, vb.)
- **WaterTracking**: Su tüketim kayıtları
- **NutritionLog**: Beslenme kayıtları
- **Workout**: Antrenman programları
- **WorkoutExercise**: Antrenman egzersizleri
- **WorkoutLog**: Tamamlanan antrenman kayıtları

## Güvenlik

- Şifreler bcrypt ile hash'leniyor (10 round)
- JWT token ile authentication
- Her endpoint (auth hariç) token gerektirir
- Kullanıcılar sadece kendi verilerine erişebilir

## Geliştirme Komutları

```bash
# Development mode (nodemon ile hot reload)
npm run dev

# Production mode
npm start

# Yeni migration oluştur
npm run db:migrate

# Veritabanını sync et (migration oluşturmadan)
npm run db:push

# Prisma Studio'yu aç
npm run db:studio

# Prisma Client'ı yeniden oluştur
npm run db:generate
```

## Hata Kodları

- `400` - Bad Request (validation hatası)
- `401` - Unauthorized (token geçersiz/yok)
- `403` - Forbidden (yetki yok)
- `404` - Not Found (kaynak bulunamadı)
- `500` - Internal Server Error

## Production Deployment

### PostgreSQL'e Geçiş

Production'da SQLite yerine PostgreSQL kullanmak için:

1. `prisma/schema.prisma` dosyasında:
```prisma
datasource db {
  provider = "postgresql"
}
```

2. `prisma.config.ts` dosyasında DATABASE_URL'i PostgreSQL connection string'e çevir:
```
postgresql://username:password@host:5432/database?schema=public
```

3. Migration'ları yeniden çalıştır:
```bash
npm run db:migrate
```

## Teknoloji Stack

- **Runtime**: Node.js
- **Framework**: Express.js
- **Database**: SQLite (Dev), PostgreSQL (Prod önerilir)
- **ORM**: Prisma
- **Authentication**: JWT + bcryptjs
- **Validation**: Joi
- **CORS**: cors
