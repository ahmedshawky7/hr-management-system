# 🏢 HR Management System

نظام إدارة موارد بشرية متكامل بـ **Spring Boot** مع مصادقة **JWT** وصلاحيات مبنية على الأدوار (Role-Based Access Control).

[![Java](https://img.shields.io/badge/Java-21-orange?style=flat-square&logo=java)](https://www.oracle.com/java/)
[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-4.1-brightgreen?style=flat-square&logo=spring)](https://spring.io/projects/spring-boot)
[![MySQL](https://img.shields.io/badge/MySQL-8.0-blue?style=flat-square&logo=mysql)](https://www.mysql.com/)
[![License](https://img.shields.io/badge/License-MIT-yellow?style=flat-square)](LICENSE)

---

## 📋 نبذة عن المشروع

نظام Backend كامل لإدارة الموظفين والإجازات في الشركات، مبني على معمارية نظيفة (Clean Architecture) مع فصل واضح بين الطبقات:

- **Controller Layer** — استقبال الطلبات
- **Service Layer** — منطق العمل
- **Repository Layer** — الوصول للبيانات
- **DTO Layer** — نقل البيانات مع Validation شامل

---

## ✨ الميزات

### 🔐 المصادقة والصلاحيات
- تسجيل دخول بـ **JWT** (صلاحية 14 يوم)
- تشفير كلمات السر بـ **BCrypt**
- 4 أدوار مختلفة مع هرمية واضحة
- صلاحيات مبنية على الدور + الملكية (`@PreAuthorize` + Custom Security Utils)
- استرجاع كلمة السر عبر الإيميل
- تفعيل الحسابات عبر رابط إيميل

### 👥 إدارة الموظفين
- CRUD كامل للموظفين
- Pagination
- هرمية إدارية (Manager → Subordinates)
- عرض الموظفين حسب القسم
- Validation شامل

### 🏢 إدارة الأقسام
- CRUD كامل للأقسام
- حماية من حذف قسم فيه موظفين
- حماية من إنشاء قسم مكرر

### 🌴 إدارة الإجازات
- طلب إجازة (مع Validation للتواريخ)
- مدير/أدمن يوافق أو يرفض
- الموظف يلغي طلبه (لو لسه PENDING)
- عرض الطلبات المعلقة حسب الدور:
  - **Admin/HR** → كل الطلبات
  - **Manager** → طلبات فريقه فقط

### 🛡️ الأمان
- JWT Filter على كل الطلبات
- معالجة مخصصة لـ **401** و **403**
- منع التسلسل اللانهائي في JSON (`@JsonIgnore`)
- فحوصات قبل كل عملية حذف

### 📊 معالجة الأخطاء
- **Global Exception Handler** موحد
- ردود JSON متسقة (`GlobalResponse<T>`)
- رسائل خطأ واضحة
- Validation منظم على كل DTO

---

## 🛠️ التقنيات المستخدمة

| التقنية | الإصدار | الاستخدام |
|---------|---------|-----------|
| **Java** | 21 | اللغة الأساسية |
| **Spring Boot** | 4.1 | إطار العمل |
| **Spring Security** | 7.x | المصادقة والصلاحيات |
| **Spring Data JPA** | 4.x | طبقة البيانات |
| **Hibernate** | 7.x | ORM |
| **MySQL** | 8.0 | قاعدة البيانات |
| **JJWT** | 0.12+ | JWT Tokens |
| **Lombok** | 1.18+ | تقليل الكود المتكرر |
| **Jakarta Validation** | 3.x | التحقق من البيانات |
| **Spring Mail** | — | إرسال الإيميلات |
| **Maven** | 3.9+ | إدارة المشروع |

---

## 🏗️ معمارية المشروع
