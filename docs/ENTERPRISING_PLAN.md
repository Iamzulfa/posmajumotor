# PosFELIX Enterprise Plan

## Multi-Tenant Architecture untuk Penjualan ke Toko Besar

Dokumen ini menjelaskan arsitektur dan implementasi untuk menjual PosFELIX ke banyak toko dengan database terpisah per tenant.

---

## Daftar Isi

1. [Overview](#overview)
2. [Opsi Arsitektur](#opsi-arsitektur)
3. [Arsitektur yang Direkomendasikan](#arsitektur-yang-direkomendasikan)
4. [Schema Central Database](#schema-central-database)
5. [Edge Functions](#edge-functions)
6. [Flutter Implementation](#flutter-implementation)
7. [User Flow](#user-flow)
8. [Provisioning New Tenant](#provisioning-new-tenant)
9. [Keuntungan](#keuntungan)

---

## Overview

Ketika menjual aplikasi POS ke banyak toko besar, tidak praktis menggunakan satu database untuk semua tenant karena:

- Risiko data leak antar toko
- Performance menurun seiring bertambahnya data
- Sulit melakukan backup/restore per toko
- Compliance issue (beberapa toko minta data terpisah)

Solusinya adalah **Multi-Tenant Architecture** dengan database terpisah per toko.

---

## Opsi Arsitektur

### Opsi 1: Single Database, Multi-Tenant (Row-Level Security)

```
┌─────────────────────────────────────┐
│         1 Supabase Project          │
│  ┌─────────────────────────────┐    │
│  │  stores table               │    │
│  │  - id, name, subscription   │    │
│  ├─────────────────────────────┤    │
│  │  Semua tabel + store_id     │    │
│  │  products.store_id          │    │
│  │  transactions.store_id      │    │
│  │  users.store_id             │    │
│  └─────────────────────────────┘    │
│  + Row Level Security (RLS)         │
└─────────────────────────────────────┘
```

**Pro:** Simple, murah, 1 deployment
**Kontra:** Data semua toko di 1 tempat, scaling terbatas, risiko data leak jika RLS salah

---

### Opsi 2: Database per Tenant (RECOMMENDED)

```
┌──────────────────────────────────────────────────────┐
│              Central Management Server               │
│  ┌────────────────────────────────────────────────┐  │
│  │  Master DB (Supabase/PostgreSQL)               │  │
│  │  - tenants (id, name, db_url, db_key, status)  │  │
│  │  - subscriptions                               │  │
│  │  - billing                                     │  │
│  └────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────┘
           │
           ▼ API: getTenantCredentials(license_key)
┌──────────┬──────────┬──────────┐
│ Toko A   │ Toko B   │ Toko C   │
│ Supabase │ Supabase │ Supabase │
│ Project  │ Project  │ Project  │
└──────────┴──────────┴──────────┘
```

**Flow:**

1. Toko beli lisensi → dapat `license_key`
2. App pertama kali dibuka → input license key
3. App call Central API → dapat `supabase_url` + `anon_key`
4. App simpan credentials di secure storage
5. App connect ke Supabase toko tersebut

**Pro:** Isolasi data sempurna, scalable, compliance ready
**Kontra:** Lebih kompleks, biaya per-project

---

### Opsi 3: Hybrid (Multiple Schemas)

```
┌─────────────────────────────────────────────────┐
│           Central Supabase (Management)         │
│  - tenants, licenses, billing                   │
│  - Edge Function: provision new tenant          │
└─────────────────────────────────────────────────┘
                    │
    ┌───────────────┼───────────────┐
    ▼               ▼               ▼
┌─────────┐   ┌─────────┐   ┌─────────┐
│ Toko A  │   │ Toko B  │   │ Toko C  │
│ Schema  │   │ Schema  │   │ Schema  │
│ (RLS)   │   │ (RLS)   │   │ (RLS)   │
└─────────┴───┴─────────┴───┴─────────┘
        1 Supabase Project
        Multiple Schemas
```

**Pro:** Lebih murah dari Opsi 2, isolasi cukup baik
**Kontra:** Masih dalam 1 project, scaling terbatas

---

## Arsitektur yang Direkomendasikan

Untuk POS toko besar, **Opsi 2 (Database per Tenant)** adalah yang paling cocok.

### Diagram Lengkap

```
┌─────────────────────────────────────────────────────────────────┐
│                    CENTRAL MANAGEMENT                           │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │  Supabase Project: posfelix-central                       │  │
│  │                                                           │  │
│  │  Tables:                                                  │  │
│  │  ├── tenants (info toko)                                  │  │
│  │  ├── licenses (lisensi & aktivasi)                        │  │
│  │  ├── subscriptions (langganan & billing)                  │  │
│  │  └── tenant_credentials (encrypted db credentials)        │  │
│  │                                                           │  │
│  │  Edge Functions:                                          │  │
│  │  ├── /activate-license                                    │  │
│  │  ├── /get-credentials                                     │  │
│  │  ├── /provision-tenant (auto create new Supabase)         │  │
│  │  └── /check-subscription                                  │  │
│  └───────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ HTTPS API
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      TENANT DATABASES                           │
│                                                                 │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐             │
│  │ Toko Jaya   │  │ Toko Makmur │  │ Toko Sentosa│   ...       │
│  │ Motor       │  │ Parts       │  │ Sparepart   │             │
│  │             │  │             │  │             │             │
│  │ Supabase    │  │ Supabase    │  │ Supabase    │             │
│  │ Project A   │  │ Project B   │  │ Project C   │             │
│  │             │  │             │  │             │             │
│  │ - products  │  │ - products  │  │ - products  │             │
│  │ - trans...  │  │ - trans...  │  │ - trans...  │             │
│  │ - users     │  │ - users     │  │ - users     │             │
│  │ - etc       │  │ - etc       │  │ - etc       │             │
│  └─────────────┘  └─────────────┘  └─────────────┘             │
└─────────────────────────────────────────────────────────────────┘
```

---

## Schema Central Database

```sql
-- Central Supabase: posfelix-central

-- =============================================
-- TABEL TENANT (Info Toko)
-- =============================================
CREATE TABLE tenants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,           -- "Toko Jaya Motor"
    owner_name VARCHAR(255) NOT NULL,
    owner_email VARCHAR(255) NOT NULL,
    owner_phone VARCHAR(20),
    address TEXT,
    status VARCHAR(20) DEFAULT 'ACTIVE',  -- ACTIVE, SUSPENDED, TERMINATED
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================
-- TABEL LISENSI
-- =============================================
CREATE TABLE licenses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID REFERENCES tenants(id),
    license_key VARCHAR(50) UNIQUE NOT NULL,  -- "POSF-XXXX-XXXX-XXXX"
    device_id VARCHAR(255),                    -- Hardware ID untuk binding
    activated_at TIMESTAMPTZ,
    expires_at TIMESTAMPTZ,
    max_devices INT DEFAULT 1,
    status VARCHAR(20) DEFAULT 'PENDING',      -- PENDING, ACTIVE, EXPIRED, REVOKED
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================
-- TABEL KREDENSIAL DATABASE TENANT (ENCRYPTED!)
-- =============================================
CREATE TABLE tenant_credentials (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID REFERENCES tenants(id) UNIQUE,
    supabase_url TEXT NOT NULL,               -- Encrypted
    supabase_anon_key TEXT NOT NULL,          -- Encrypted
    supabase_service_key TEXT,                -- Encrypted (untuk admin ops)
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================
-- TABEL SUBSCRIPTION/BILLING
-- =============================================
CREATE TABLE subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID REFERENCES tenants(id),
    plan VARCHAR(50) NOT NULL,                -- STARTER, PROFESSIONAL, ENTERPRISE
    price_monthly INT NOT NULL,
    started_at TIMESTAMPTZ DEFAULT NOW(),
    expires_at TIMESTAMPTZ,
    auto_renew BOOLEAN DEFAULT true,
    status VARCHAR(20) DEFAULT 'ACTIVE'       -- ACTIVE, EXPIRED, CANCELLED
);

-- =============================================
-- INDEXES
-- =============================================
CREATE INDEX idx_licenses_key ON licenses(license_key);
CREATE INDEX idx_licenses_tenant ON licenses(tenant_id);
CREATE INDEX idx_subscriptions_tenant ON subscriptions(tenant_id);
```

---

## Edge Functions

### 1. Activate License

```typescript
// supabase/functions/activate-license/index.ts

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { license_key, device_id } = await req.json();

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    // 1. Cek lisensi valid
    const { data: license, error: licenseError } = await supabase
      .from("licenses")
      .select(
        `
        *,
        tenant:tenants(*),
        subscription:subscriptions(*)
      `
      )
      .eq("license_key", license_key)
      .single();

    if (licenseError || !license) {
      return new Response(
        JSON.stringify({ error: "License key tidak valid" }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // 2. Cek status lisensi
    if (license.status === "REVOKED") {
      return new Response(JSON.stringify({ error: "License telah dicabut" }), {
        status: 403,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    if (
      license.status === "EXPIRED" ||
      (license.expires_at && new Date(license.expires_at) < new Date())
    ) {
      return new Response(JSON.stringify({ error: "License telah expired" }), {
        status: 403,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // 3. Cek device binding (opsional)
    if (license.device_id && license.device_id !== device_id) {
      return new Response(
        JSON.stringify({ error: "License sudah digunakan di device lain" }),
        {
          status: 403,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // 4. Aktivasi jika belum
    if (license.status === "PENDING") {
      await supabase
        .from("licenses")
        .update({
          status: "ACTIVE",
          device_id: device_id,
          activated_at: new Date().toISOString(),
        })
        .eq("id", license.id);
    }

    // 5. Ambil credentials tenant
    const { data: credentials } = await supabase
      .from("tenant_credentials")
      .select("supabase_url, supabase_anon_key")
      .eq("tenant_id", license.tenant_id)
      .single();

    if (!credentials) {
      return new Response(
        JSON.stringify({ error: "Database tenant belum di-setup" }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // 6. Return credentials (decrypt jika perlu)
    return new Response(
      JSON.stringify({
        success: true,
        tenant: {
          id: license.tenant.id,
          name: license.tenant.name,
        },
        subscription: {
          plan: license.subscription?.plan || "STARTER",
          expires_at: license.subscription?.expires_at,
        },
        credentials: {
          supabase_url: decrypt(credentials.supabase_url),
          supabase_anon_key: decrypt(credentials.supabase_anon_key),
        },
      }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});

function decrypt(encrypted: string): string {
  // Implement decryption dengan AES atau sejenisnya
  // Untuk production, gunakan Vault atau KMS
  return encrypted; // placeholder
}
```

### 2. Check Subscription

```typescript
// supabase/functions/check-subscription/index.ts

serve(async (req) => {
  const { license_key } = await req.json();

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
  );

  const { data: license } = await supabase
    .from("licenses")
    .select("*, subscription:subscriptions(*)")
    .eq("license_key", license_key)
    .single();

  if (!license) {
    return new Response(
      JSON.stringify({ valid: false, reason: "License not found" })
    );
  }

  const subscription = license.subscription;
  const isValid =
    subscription &&
    subscription.status === "ACTIVE" &&
    (!subscription.expires_at ||
      new Date(subscription.expires_at) > new Date());

  return new Response(
    JSON.stringify({
      valid: isValid,
      plan: subscription?.plan,
      expires_at: subscription?.expires_at,
    })
  );
});
```

---

## Flutter Implementation

### 1. Tenant Service

```dart
// lib/core/services/tenant_service.dart

import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class TenantCredentials {
  final String tenantId;
  final String tenantName;
  final String supabaseUrl;
  final String supabaseAnonKey;
  final String plan;
  final DateTime? expiresAt;

  TenantCredentials({
    required this.tenantId,
    required this.tenantName,
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.plan,
    this.expiresAt,
  });

  factory TenantCredentials.fromJson(Map<String, dynamic> json) {
    return TenantCredentials(
      tenantId: json['tenant']['id'],
      tenantName: json['tenant']['name'],
      supabaseUrl: json['credentials']['supabase_url'],
      supabaseAnonKey: json['credentials']['supabase_anon_key'],
      plan: json['subscription']['plan'],
      expiresAt: json['subscription']['expires_at'] != null
          ? DateTime.parse(json['subscription']['expires_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'tenant_id': tenantId,
    'tenant_name': tenantName,
    'supabase_url': supabaseUrl,
    'supabase_anon_key': supabaseAnonKey,
    'plan': plan,
    'expires_at': expiresAt?.toIso8601String(),
  };
}

class TenantService {
  static const _centralApiUrl = 'https://YOUR-CENTRAL-PROJECT.supabase.co/functions/v1';
  static const _storage = FlutterSecureStorage();

  static TenantCredentials? _credentials;

  /// Get current tenant credentials
  static TenantCredentials? get credentials => _credentials;

  /// Check if tenant is configured
  static bool get isConfigured => _credentials != null;

  /// Initialize from secure storage (called on app start)
  static Future<bool> initialize() async {
    try {
      final stored = await _storage.read(key: 'tenant_credentials');
      if (stored != null) {
        final json = jsonDecode(stored);
        _credentials = TenantCredentials(
          tenantId: json['tenant_id'],
          tenantName: json['tenant_name'],
          supabaseUrl: json['supabase_url'],
          supabaseAnonKey: json['supabase_anon_key'],
          plan: json['plan'],
          expiresAt: json['expires_at'] != null
              ? DateTime.parse(json['expires_at'])
              : null,
        );
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Activate license and get credentials
  static Future<TenantCredentials> activateLicense({
    required String licenseKey,
    required String deviceId,
  }) async {
    final response = await http.post(
      Uri.parse('$_centralApiUrl/activate-license'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'license_key': licenseKey,
        'device_id': deviceId,
      }),
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Aktivasi gagal');
    }

    final data = jsonDecode(response.body);
    _credentials = TenantCredentials.fromJson(data);

    // Save to secure storage
    await _storage.write(
      key: 'tenant_credentials',
      value: jsonEncode(_credentials!.toJson()),
    );

    // Save license key for re-validation
    await _storage.write(key: 'license_key', value: licenseKey);

    return _credentials!;
  }

  /// Validate subscription (call periodically)
  static Future<bool> validateSubscription() async {
    final licenseKey = await _storage.read(key: 'license_key');
    if (licenseKey == null) return false;

    try {
      final response = await http.post(
        Uri.parse('$_centralApiUrl/check-subscription'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'license_key': licenseKey}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['valid'] == true;
      }
      return false;
    } catch (e) {
      // Offline - allow grace period
      return true;
    }
  }

  /// Clear credentials (logout/reset)
  static Future<void> clear() async {
    _credentials = null;
    await _storage.delete(key: 'tenant_credentials');
    await _storage.delete(key: 'license_key');
  }
}
```

---

### 2. Modified Supabase Config

```dart
// lib/config/constants/supabase_config.dart

import 'package:posfelix/core/services/tenant_service.dart';

class SupabaseConfig {
  /// Check if Supabase is configured (tenant activated)
  static bool get isConfigured => TenantService.isConfigured;

  /// Get Supabase URL from tenant credentials
  static String get supabaseUrl {
    if (!isConfigured) {
      throw Exception('Tenant not configured. Please activate license first.');
    }
    return TenantService.credentials!.supabaseUrl;
  }

  /// Get Supabase Anon Key from tenant credentials
  static String get supabaseAnonKey {
    if (!isConfigured) {
      throw Exception('Tenant not configured. Please activate license first.');
    }
    return TenantService.credentials!.supabaseAnonKey;
  }

  /// Tenant info
  static String get tenantName => TenantService.credentials?.tenantName ?? '';
  static String get plan => TenantService.credentials?.plan ?? 'STARTER';
}
```

### 3. License Activation Screen

```dart
// lib/presentation/screens/activation/license_activation_screen.dart

import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

class LicenseActivationScreen extends StatefulWidget {
  const LicenseActivationScreen({super.key});

  @override
  State<LicenseActivationScreen> createState() => _LicenseActivationScreenState();
}

class _LicenseActivationScreenState extends State<LicenseActivationScreen> {
  final _licenseController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  Future<String> _getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final android = await deviceInfo.androidInfo;
      return android.id;
    } else if (Platform.isIOS) {
      final ios = await deviceInfo.iosInfo;
      return ios.identifierForVendor ?? '';
    }
    return 'unknown';
  }

  Future<void> _activateLicense() async {
    final licenseKey = _licenseController.text.trim();
    if (licenseKey.isEmpty) {
      setState(() => _error = 'Masukkan license key');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final deviceId = await _getDeviceId();

      await TenantService.activateLicense(
        licenseKey: licenseKey,
        deviceId: deviceId,
      );

      // Initialize Supabase with new credentials
      await Supabase.initialize(
        url: SupabaseConfig.supabaseUrl,
        anonKey: SupabaseConfig.supabaseAnonKey,
      );

      // Navigate to login
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Image.asset('assets/images/logo.png', height: 80),
              const SizedBox(height: 32),

              // Title
              const Text(
                'Aktivasi PosFELIX',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Masukkan license key untuk mengaktifkan aplikasi',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),

              // License input
              TextField(
                controller: _licenseController,
                decoration: InputDecoration(
                  labelText: 'License Key',
                  hintText: 'POSF-XXXX-XXXX-XXXX',
                  prefixIcon: const Icon(Icons.vpn_key),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  errorText: _error,
                ),
                textCapitalization: TextCapitalization.characters,
              ),
              const SizedBox(height: 24),

              // Activate button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _activateLicense,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20, width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Aktivasi'),
                ),
              ),

              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  // Open purchase page
                  launchUrl(Uri.parse('https://posfelix.com/pricing'));
                },
                child: const Text('Belum punya license? Beli di sini'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

### 4. Modified Main.dart

```dart
// lib/main.dart

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Try to load existing tenant credentials
  final hasTenant = await TenantService.initialize();

  if (hasTenant) {
    // Initialize Supabase with tenant credentials
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );
  }

  runApp(
    ProviderScope(
      child: MyApp(showActivation: !hasTenant),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool showActivation;

  const MyApp({super.key, required this.showActivation});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PosFELIX',
      home: showActivation
          ? const LicenseActivationScreen()
          : const AuthWrapper(),
    );
  }
}
```

---

## User Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                        USER FLOW                                │
└─────────────────────────────────────────────────────────────────┘

  ┌──────────┐     ┌──────────────┐     ┌─────────────────┐
  │  Install │────▶│ First Open   │────▶│ License Screen  │
  │   App    │     │ No Tenant    │     │ Input Key       │
  └──────────┘     └──────────────┘     └────────┬────────┘
                                                  │
                                                  ▼
                                        ┌─────────────────┐
                                        │ Call Central    │
                                        │ API: activate   │
                                        └────────┬────────┘
                                                  │
                          ┌───────────────────────┼───────────────────────┐
                          │                       │                       │
                          ▼                       ▼                       ▼
                   ┌─────────────┐        ┌─────────────┐        ┌─────────────┐
                   │   Invalid   │        │   Expired   │        │   Success   │
                   │   License   │        │   License   │        │ Get Creds   │
                   └─────────────┘        └─────────────┘        └──────┬──────┘
                          │                       │                      │
                          ▼                       ▼                      ▼
                   ┌─────────────┐        ┌─────────────┐        ┌─────────────┐
                   │ Show Error  │        │ Show Renew  │        │ Save Creds  │
                   │             │        │ Link        │        │ to Secure   │
                   └─────────────┘        └─────────────┘        │ Storage     │
                                                                 └──────┬──────┘
                                                                        │
                                                                        ▼
                                                                 ┌─────────────┐
                                                                 │ Init        │
                                                                 │ Supabase    │
                                                                 │ with Creds  │
                                                                 └──────┬──────┘
                                                                        │
                                                                        ▼
                                                                 ┌─────────────┐
                                                                 │ Login       │
                                                                 │ Screen      │
                                                                 └──────┬──────┘
                                                                        │
                                                                        ▼
                                                                 ┌─────────────┐
                                                                 │ App Ready   │
                                                                 │ Use Tenant  │
                                                                 │ Database    │
                                                                 └─────────────┘
```

---

## Provisioning New Tenant

Ketika ada toko baru beli lisensi, ada 2 cara:

### Cara Manual (Recommended untuk awal)

1. **Admin create Supabase project** untuk toko baru
2. **Run schema.sql** untuk create semua tabel
3. **Input credentials** ke central database:

   ```sql
   -- Di Central DB
   INSERT INTO tenants (name, owner_name, owner_email)
   VALUES ('Toko Jaya Motor', 'Budi', 'budi@tokojaya.com');

   INSERT INTO tenant_credentials (tenant_id, supabase_url, supabase_anon_key)
   VALUES (
     'tenant-uuid-here',
     'https://xxxxx.supabase.co',
     'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'
   );

   INSERT INTO licenses (tenant_id, license_key, expires_at)
   VALUES (
     'tenant-uuid-here',
     'POSF-JAYA-2024-XXXX',
     '2025-12-31'
   );

   INSERT INTO subscriptions (tenant_id, plan, price_monthly)
   VALUES ('tenant-uuid-here', 'PROFESSIONAL', 500000);
   ```

4. **Kirim license key** ke customer

### Cara Otomatis (Advanced)

```typescript
// supabase/functions/provision-tenant/index.ts

// 1. Create new Supabase project via Management API
const project = await supabaseManagement.createProject({
  name: `posfelix-${tenantSlug}`,
  organization_id: ORG_ID,
  region: "ap-southeast-1",
  plan: "free", // atau 'pro'
});

// 2. Wait for project ready
await waitForProjectReady(project.id);

// 3. Run migration SQL
await supabaseManagement.runSQL(project.id, schemaSQL);

// 4. Get credentials
const credentials = await supabaseManagement.getAPIKeys(project.id);

// 5. Store in central DB
await centralDB.from("tenant_credentials").insert({
  tenant_id: tenantId,
  supabase_url: project.url,
  supabase_anon_key: credentials.anon_key,
  supabase_service_key: credentials.service_key,
});

// 6. Generate license key
const licenseKey = generateLicenseKey();
await centralDB.from("licenses").insert({
  tenant_id: tenantId,
  license_key: licenseKey,
});

return { license_key: licenseKey };
```

---

## Keuntungan Arsitektur Ini

| Aspek              | Keuntungan                                         |
| ------------------ | -------------------------------------------------- |
| **Isolasi Data**   | Data toko A tidak mungkin bocor ke toko B          |
| **Performance**    | Tidak ada query yang bersaing antar toko           |
| **Compliance**     | Memenuhi requirement toko yang minta data terpisah |
| **Scaling**        | Bisa upgrade per-toko sesuai kebutuhan             |
| **Backup/Restore** | Bisa per-toko, tidak affect toko lain              |
| **Maintenance**    | Update schema bisa bertahap per-tenant             |
| **Billing**        | Subscription tracking built-in                     |
| **Security**       | Device binding mencegah license sharing            |
| **Offline**        | Credentials tersimpan lokal, app tetap jalan       |

---

## Pricing Suggestion

| Plan             | Fitur                                                | Harga/bulan  |
| ---------------- | ---------------------------------------------------- | ------------ |
| **STARTER**      | 1 device, 1 user, basic features                     | Rp 200.000   |
| **PROFESSIONAL** | 3 devices, 5 users, analytics, export                | Rp 500.000   |
| **ENTERPRISE**   | Unlimited devices, unlimited users, priority support | Rp 1.500.000 |

---

## Dependencies Tambahan

```yaml
# pubspec.yaml
dependencies:
  flutter_secure_storage: ^9.0.0 # Untuk simpan credentials
  device_info_plus: ^9.0.0 # Untuk device binding
  http: ^1.1.0 # Untuk call central API
```

---

## Security Considerations

1. **Encrypt credentials** di central database (gunakan pgcrypto atau external KMS)
2. **HTTPS only** untuk semua API calls
3. **Device binding** untuk mencegah license sharing
4. **Periodic validation** untuk cek subscription status
5. **Grace period** untuk offline mode (misal 7 hari)
6. **Obfuscate** Flutter code untuk production

---

## Next Steps

1. [ ] Setup Central Supabase Project
2. [ ] Create central database schema
3. [ ] Deploy Edge Functions
4. [ ] Implement TenantService di Flutter
5. [ ] Create License Activation Screen
6. [ ] Modify main.dart untuk check tenant
7. [ ] Test end-to-end flow
8. [ ] Setup billing/payment gateway

---

_Dokumen ini dibuat sebagai panduan implementasi multi-tenant architecture untuk PosFELIX Enterprise._
