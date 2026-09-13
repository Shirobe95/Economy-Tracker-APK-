# Publicar una versión firmada

El APK que genera GitHub Actions está firmado con la clave de depuración:
sirve para instalarlo en tu móvil, pero **no** para publicar en Google Play
ni para actualizar sobre una versión firmada con otra clave.

## Por qué importa la clave

Android identifica una aplicación por su paquete **y su firma**. Si instalas
un APK firmado con la clave de depuración y más adelante generas otro con tu
clave propia, Android lo trata como una aplicación distinta y **se niega a
actualizar**: tendrías que desinstalar primero, y desinstalar borra la base
de datos. Haz una copia de seguridad antes de cambiar de clave.

Si pierdes la clave con la que publicaste, no hay forma de actualizar esa
aplicación nunca más. Guárdala como guardarías la escritura de un piso.

## Generar la clave, una sola vez

```bash
keytool -genkey -v \
  -keystore ~/economy-tracker.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias economy-tracker
```

Guarda el `.jks` y su contraseña fuera del proyecto, en un gestor de
contraseñas o un disco cifrado. Nunca dentro del repositorio.

## Configurar la firma en local

Crea `android/key.properties` (está en `.gitignore`, no se sube):

```properties
storeFile=/ruta/absoluta/a/economy-tracker.jks
storePassword=tu-contraseña
keyAlias=economy-tracker
keyPassword=tu-contraseña
```

Con ese archivo presente, `flutter build apk --release` firma con tu clave.
Sin él, sigue compilando con la de depuración.

## Firmar en GitHub Actions

Si algún día quieres que el APK de CI vaya firmado, hace falta guardar la
clave como secreto del repositorio (el `.jks` en base64 y las contraseñas) y
reconstruir `key.properties` en el runner antes de compilar. No está
configurado: mientras el APK sea solo para tu móvil, la firma de depuración
basta, y menos secretos en circulación es menos superficie de riesgo.

## Qué NO está implementado

- Publicación en Google Play, ficha de tienda ni App Bundle (`.aab`).
- Firma en CI, por lo dicho arriba.
- Cifrado de la base de datos en reposo.
