# Windows 11: clic derecho «Copiar ruta absoluta»

Con un solo clic derecho copias la ruta absoluta de un archivo/carpeta al portapapeles, con una opción con comillas. Solo PowerShell + registro de Windows: sin software adicional, sin permisos de administrador, fácil de desinstalar.

> Creado para resolver el incordio de «guardar una imagen y luego escribir la ruta completa a mano en un chat de IA»: clic derecho → copiar ruta → pegar.

🌐 **Idioma**: [简体中文](../README.md) | [繁體中文](README.zh-Hant.md) | [English](README.en.md) | [日本語](README.ja.md) | [Español](README.es.md)

---

## Características

- Clic derecho en **archivo / carpeta / unidad** → «Mostrar más opciones» → «Copiar ruta absoluta»
- Opción «Copiar ruta absoluta (con comillas)» para pegarla en argumentos de línea de comandos
- Solo PowerShell + registro: sin programas extra, sin procesos en segundo plano, sin red
- Escribe solo en el registro del usuario actual (`HKCU`): sin administrador, 100 % reversible
- Probado con rutas que contienen **caracteres chinos, espacios y corchetes**

## Uso

### 1. Instalar (una vez)

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\Install-CopyPath.ps1
```

### 2. Usar

Clic derecho en un archivo/carpeta → «Mostrar más opciones» → «Copiar ruta absoluta». Espera ~1 segundo y pega donde quieras.

### 3. Estado / desinstalar

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\Install-CopyPath.ps1 -Status
powershell -NoProfile -ExecutionPolicy Bypass -File .\Install-CopyPath.ps1 -Remove
```

## Cómo funciona

- `CopyPath.ps1` — resuelve la ruta y la escribe en el portapapeles
- `Install-CopyPath.ps1` — crea las entradas en `HKCU\Software\Classes\*\shell` (y `Directory`, `Drive`); el elemento ejecuta `powershell.exe` oculto → `CopyPath.ps1` con `%1` (la ruta sobre la que hiciste clic)
- La instalación copia `CopyPath.ps1` a `%LOCALAPPDATA%\CodexTools\CopyAbsolutePath\`, que es lo que llama el menú

## Preguntas frecuentes

- **¿No aparece en Windows 11?** Los elementos estáticos del registro van en «Mostrar más opciones». Para el nuevo menú compacto se necesitan herramientas como Nilesoft Shell.
- **¿Texto chino corrupto?** Los scripts están en UTF-8 con BOM; mantén esa codificación si los editas.
- **¿Borré el script de trabajo?** El menú deja de funcionar; vuelve a ejecutar el instalador.
- **¿Funciona en Windows 10?** Sí, mismo mecanismo.

## Licencia

[MIT](../LICENSE)