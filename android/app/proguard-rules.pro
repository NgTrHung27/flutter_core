# Ví dụ: Giữ lại toàn bộ code của Firebase và Google Services
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Giữ lại các class dùng cho việc Parse JSON (như Gson nếu có xài ở Native)
-keepattributes Signature
-keepattributes *Annotation*
-keep class sun.misc.Unsafe { *; }