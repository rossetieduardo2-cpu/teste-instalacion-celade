# =============================================================================
#  INSTALACIÓN DE PAQUETES PARA EL CURSO CELADE 2026 - PROYECCIONES SUBNACIONALES
#  Sistema operativo: macOS
#  Versión de R del curso: 4.3.0
# =============================================================================
#
#  ¿QUÉ HACE ESTE SCRIPT?
#  ----------------------
#  Instala TODOS los paquetes de R necesarios para los ejercicios del curso:
#    1. Paquetes de CRAN (dplyr, ggplot2, sf, leaflet, openxlsx, etc.)
#    2. DemoTools (versión "workshop" de IvanWilli) y sus dependencias de GitHub
#    3. El paquete del curso: ProjSubnacional (GitLab de CEPAL)
#  Al final, ejecuta una verificación y muestra una tabla con el resultado.
#
#  ¿CÓMO EJECUTARLO?
#  -----------------
#  1. Abra este archivo en RStudio.
#  2. Ejecute TODO el script de una vez:
#        - Botón "Source" (arriba a la derecha del editor), o
#        - Atajo de teclado: Cmd + Shift + S
#  3. Espere. La instalación puede tardar entre 10 y 40 minutos según la
#     velocidad de internet. Verá mucho texto en rojo en la consola: eso es
#     NORMAL (R muestra el progreso de las descargas en rojo). Solo preocúpese
#     si al final el script indica que algún paquete quedó "NO INSTALADO".
#  4. Si el script se detiene con un error, lea el mensaje: casi todos los
#     errores esperados tienen una explicación en el propio mensaje y en la
#     sección "SOLUCIÓN DE PROBLEMAS" al final de este archivo.
#
#  PREGUNTAS QUE PUEDEN APARECER EN LA CONSOLA
#  -------------------------------------------
#  Durante la instalación, R puede detenerse y esperar que usted escriba una
#  respuesta en la consola (abajo en RStudio). Antes de cada paso del script
#  donde esto puede ocurrir hay un recuadro "SI APARECE UNA PREGUNTA" que
#  indica exactamente qué responder. Escriba la respuesta y presione ENTER.
#
#  REQUISITOS PREVIOS
#  ------------------
#   • R 4.3.0 para macOS, según su procesador:
#       - Apple Silicon (M1/M2/M3/M4): R-4.3.0-arm64.pkg
#       - Intel:                       R-4.3.0.pkg (x86_64)
#     Descarga: https://cran.r-project.org/bin/macosx/
#     (¿Qué procesador tengo? Menú Apple  > Acerca de este Mac > "Chip" o
#      "Procesador".)
#   • RStudio Desktop (versión reciente): https://posit.co/download/rstudio-desktop/
#   • NO es necesario instalar Xcode: todos los paquetes se instalan ya
#     compilados (binarios).
#   • Si macOS muestra una ventana pidiendo instalar las "herramientas de
#     línea de comandos" (command line developer tools), puede pulsar
#     "Cancelar": no son necesarias para este script.
# =============================================================================


# -----------------------------------------------------------------------------
# PASO 0. Preparación
# -----------------------------------------------------------------------------
# Limpiamos el entorno para evitar conflictos con objetos de sesiones previas.
rm(list = ls())

# Mensajes de progreso más legibles
paso <- function(txt) {
  cat("\n", strrep("=", 70), "\n  ", txt, "\n", strrep("=", 70), "\n", sep = "")
}

# Ubicamos la carpeta donde está guardado este script (carpeta Ejercicios/_instalacion).
# Si RStudio está disponible, se detecta automáticamente.
if (requireNamespace("rstudioapi", quietly = TRUE) &&
    rstudioapi::isAvailable()) {
  ruta_script <- tryCatch(dirname(rstudioapi::getSourceEditorContext()$path),
                          error = function(e) "")
  if (nzchar(ruta_script)) setwd(ruta_script)
}
cat("Carpeta de trabajo:", getwd(), "\n")
# Si la carpeta mostrada NO es la carpeta "_instalacion", use el menú de
# RStudio: Session > Set Working Directory > To Source File Location
# y vuelva a ejecutar el script.


# -----------------------------------------------------------------------------
# PASO 1. Verificar sistema operativo y versión de R
# -----------------------------------------------------------------------------
paso("PASO 1. Verificando sistema operativo y versión de R")

so_detectado <- Sys.info()[["sysname"]]
cat("Sistema operativo detectado:", so_detectado, "\n")
cat("Versión de R:", R.version.string, "\n")

if (so_detectado != "Darwin") {
  stop("Este script es para macOS, pero su computador usa ", so_detectado,
       ".\nUse el script correspondiente a su sistema operativo:\n",
       "  - Windows: instalar_paquetes_windows.R\n",
       "  - macOS:   instalar_paquetes_mac.R\n",
       "  - Linux:   instalar_paquetes_linux.R")
}

if (getRversion() < "4.3.0") {
  stop("El curso requiere R 4.3.0 o superior. Usted tiene ", getRversion(),
       ".\nDescargue R 4.3.0 desde https://cran.r-project.org/ e instálelo.")
}
if (getRversion() >= "4.4.0") {
  message("AVISO: usted tiene R ", getRversion(), ". El curso usa R 4.3.0.\n",
          "La instalación debería funcionar, pero las versiones de los paquetes ",
          "pueden diferir de las del instructor.")
}

# Tiempo máximo de descarga ampliado (la conexión del aula puede ser lenta).
options(timeout = max(1200, getOption("timeout")))


# -----------------------------------------------------------------------------
# PASO 2. Configurar el repositorio de paquetes
# -----------------------------------------------------------------------------
paso("PASO 2. Configurando el repositorio de paquetes")

# En macOS usamos el repositorio oficial de CRAN.
# CRAN mantiene un repositorio de BINARIOS (ya compilados) específico para
# R 4.3 en Mac. Forzando el tipo "binary", R instala desde ahí y NO necesita
# compilar nada (no se requiere Xcode).
options(repos = c(CRAN = "https://cloud.r-project.org"))
options(pkgType = "binary")                # solo binarios: nunca compilar
options(install.packages.compile.from.source = "never")

# Informamos qué tipo de Mac tiene (Apple Silicon M1/M2/M3 o Intel).
arq <- Sys.info()[["machine"]]
cat("Arquitectura:", arq,
    ifelse(arq == "arm64", "(Apple Silicon)", "(Intel)"), "\n")
cat("Repositorio:", getOption("repos")[["CRAN"]], "\n")
# IMPORTANTE: la versión de R debe coincidir con su procesador.
#  - Mac con M1/M2/M3/M4 -> instalador de R "arm64"
#  - Mac Intel           -> instalador de R "x86_64"


# -----------------------------------------------------------------------------
# PASO 3. Instalar los paquetes de CRAN
# -----------------------------------------------------------------------------
paso("PASO 3. Instalando paquetes de CRAN (puede tardar varios minutos)")

# Lista de paquetes, agrupados según su uso en el curso:
paquetes_cran <- c(
  # --- Usados por el paquete ProjSubnacional ---
  "dplyr", "htmltools", "htmlwidgets", "jsonlite", "DT", "withr",
  "lubridate", "openxlsx", "base64enc", "knitr", "rmarkdown",
  # --- Manipulación de datos y gráficos (ejercicios) ---
  "tidyverse", "tidyr", "ggplot2", "scales", "plotly",
  # (Los archivos Excel de los ejercicios se leen con openxlsx, incluido
  #  arriba. No se usa readxl: en macOS con R 4.3.0 sus binarios no cargan.)
  # --- Mapas (ejercicio Brasil DPA_GEO) ---
  "sf", "leaflet",
  # --- Herramientas de instalación ---
  "remotes", "rstudioapi",
  # --- Dependencias de DemoTools disponibles en CRAN ---
  "Rcpp", "data.table", "demogR", "ungroup", "wpp2019", "minpack.lm",
  "Rdpack", "MortalityLaws", "magrittr", "rlang", "tibble", "purrr",
  "readr", "stringr", "tidyselect", "httr", "pbapply", "RCurl"
)

# +---------------------------------------------------------------------------+
# | SI APARECE UNA PREGUNTA DURANTE ESTE PASO, RESPONDA ASÍ:                  |
# |                                                                           |
# | • "Would you like to use a personal library instead? (yes/No/cancel)"     |
# |      -> escriba:  yes                                                     |
# |   (Ocurre cuando no tiene permisos de administrador. Es seguro.)          |
# |                                                                           |
# | • "Would you like to create a personal library ... to install packages    |
# |    into? (yes/No/cancel)"                                                 |
# |      -> escriba:  yes                                                     |
# |                                                                           |
# | • "Do you want to install from sources the packages which need            |
# |    compilation? (Yes/no/cancel)"                                          |
# |      -> escriba:  no                                                      |
# |   (R usará versiones ya compiladas, que no requieren herramientas         |
# |    adicionales. Es la opción más segura.)                                 |
# |                                                                           |
# | • "Selection:" con una lista de servidores (mirrors) de CRAN              |
# |      -> escriba el número de un servidor cercano (p. ej. Chile o          |
# |         "0-Cloud") y presione ENTER.                                      |
# |                                                                           |
# | • Ventana emergente de RStudio "Updating Loaded Packages ... Restart R    |
# |   prior to install?"                                                      |
# |      -> haga clic en:  Yes                                                |
# |   Después de reiniciar, vuelva a ejecutar el script completo (es seguro:  |
# |   los paquetes ya instalados se omiten).                                  |
# +---------------------------------------------------------------------------+

# Solo instalamos los que todavía NO están instalados (así el script se
# puede ejecutar varias veces sin repetir descargas).
faltan <- paquetes_cran[!vapply(paquetes_cran, requireNamespace,
                                logical(1), quietly = TRUE)]
if (length(faltan) > 0) {
  cat("Paquetes a instalar (", length(faltan), "):\n  ",
      paste(faltan, collapse = ", "), "\n", sep = "")
  install.packages(faltan, dependencies = c("Depends", "Imports", "LinkingTo"))
} else {
  cat("Todos los paquetes de CRAN ya estaban instalados.\n")
}


# -----------------------------------------------------------------------------
# PASO 4. Instalar DemoTools (versión "workshop") y sus dependencias de GitHub
# -----------------------------------------------------------------------------
paso("PASO 4. Instalando DemoTools y dependencias desde GitHub")

# DemoTools NO está en CRAN. Usamos la versión "workshop" preparada por
# Iván Williams, más liviana y sin código que deba compilarse.
# Sus dependencias de GitHub se instalan en este orden:
#   DemoToolsData -> MortalityEstimate -> fertestr -> DemoTools
#
# upgrade = "never": evita que se reemplacen paquetes ya instalados
# (en especial, impide que MortalityLaws de CRAN sea sustituido por una
# copia antigua de GitHub).
#
# NOTA SOBRE EL LÍMITE DE GITHUB: GitHub permite ~60 descargas por hora por
# red sin autenticación. Si muchos participantes instalan al mismo tiempo en
# la misma red (aula), puede aparecer el error:
#   "API rate limit exceeded" o "HTTP error 403"
# Soluciones (ver también SOLUCIÓN DE PROBLEMAS al final):
#   Espere 30-60 minutos y vuelva a ejecutar el script, o configure un
#   token de GitHub (ver SOLUCIÓN DE PROBLEMAS, punto 1).

# +---------------------------------------------------------------------------+
# | SI APARECE UNA PREGUNTA DURANTE ESTE PASO, RESPONDA ASÍ:                  |
# |                                                                           |
# | • "These packages have more recent versions available.                    |
# |    Which would you like to update?                                        |
# |    1: All   2: CRAN packages only   3: None ..."                          |
# |      -> escriba:  3      (ninguno; NO actualice durante el curso)         |
# |                                                                           |
# | • "Update all/some/none? [a/s/n]:"                                        |
# |      -> escriba:  n                                                       |
# |                                                                           |
# | • "Do you want to install from sources the packages which need            |
# |    compilation? (Yes/no/cancel)"                                          |
# |      -> escriba:  no                                                      |
# |                                                                           |
# | • Ventana emergente de RStudio "Updating Loaded Packages ... Restart R    |
# |   prior to install?"                                                      |
# |      -> haga clic en:  Yes  y luego vuelva a ejecutar el script completo. |
# +---------------------------------------------------------------------------+

paquetes_github <- list(
  list(nombre = "DemoToolsData",     repo = "timriffe/DemoToolsData",     ref = "HEAD"),
  list(nombre = "MortalityEstimate", repo = "mpascariu/MortalityEstimate", ref = "HEAD"),
  list(nombre = "fertestr",          repo = "timriffe/fertestr",          ref = "HEAD"),
  list(nombre = "DemoTools",         repo = "IvanWilli/DemoTools",        ref = "workshop")
)

for (p in paquetes_github) {
  if (requireNamespace(p$nombre, quietly = TRUE)) {
    cat(p$nombre, ": ya instalado, se omite.\n")
    next
  }
  cat("\nInstalando", p$nombre, "...\n")
  ok <- tryCatch({
      remotes::install_github(p$repo, ref = p$ref, upgrade = "never",
                              dependencies = c("Depends", "Imports"),
                              build_vignettes = FALSE, quiet = FALSE)
      requireNamespace(p$nombre, quietly = TRUE)
    }, error = function(e) {
      message("  ERROR al instalar ", p$nombre, " desde GitHub:\n  ",
              conditionMessage(e))
      FALSE
    })
  if (!ok) message("  >>> ", p$nombre, " NO se pudo instalar. ",
                   "Vea SOLUCIÓN DE PROBLEMAS al final del script.")
}


# -----------------------------------------------------------------------------
# PASO 5. Instalar el paquete del curso: ProjSubnacional
# -----------------------------------------------------------------------------
paso("PASO 5. Instalando el paquete del curso ProjSubnacional")

# ProjSubnacional se instala desde el GitLab institucional de CEPAL/CELADE:
#   https://git.cepal.org/epp_celade/projsubnacional
# El repositorio es público: no se necesita usuario ni contraseña.
# Se instala la versión más reciente disponible en el repositorio.
# Es código R puro: NO requiere compiladores (Rtools / Xcode).
#
# upgrade = "never": no reemplaza paquetes ya instalados en los pasos previos.
# +---------------------------------------------------------------------------+
# | SI APARECE UNA PREGUNTA AL INSTALAR ProjSubnacional, RESPONDA ASÍ:        |
# |                                                                           |
# | • "These packages have more recent versions available.                    |
# |    Which would you like to update?                                        |
# |    1: All   2: CRAN packages only   3: None ..."                          |
# |      -> escriba:  3      (ninguno; NO actualice durante el curso)         |
# |                                                                           |
# | • "Update all/some/none? [a/s/n]:"                                        |
# |      -> escriba:  n                                                       |
# |                                                                           |
# | • "Do you want to install from sources the packages which need            |
# |    compilation? (Yes/no/cancel)"                                          |
# |      -> escriba:  no                                                      |
# |                                                                           |
# | • Ventana emergente de RStudio "Updating Loaded Packages ... Restart R    |
# |   prior to install?"                                                      |
# |      -> haga clic en:  Yes  y luego vuelva a ejecutar el script completo. |
# +---------------------------------------------------------------------------+

ok <- tryCatch({
  remotes::install_gitlab("epp_celade/projsubnacional",
                          host = "git.cepal.org", upgrade = "never",
                          build_vignettes = FALSE)
  requireNamespace("ProjSubnacional", quietly = TRUE)
}, error = function(e) {
  message("  ERROR al instalar desde git.cepal.org:\n  ", conditionMessage(e))
  FALSE
})
if (!ok) message(">>> ProjSubnacional NO se pudo instalar. Verifique su ",
                 "conexión abriendo en el navegador ",
                 "https://git.cepal.org/epp_celade/projsubnacional ",
                 "y vuelva a ejecutar el script.")

# -----------------------------------------------------------------------------
# PASO 6. Verificación final
# -----------------------------------------------------------------------------
paso("PASO 6. Verificación final")

todos <- c(paquetes_cran, vapply(paquetes_github, `[[`, "", "nombre"),
           "ProjSubnacional")
resultado <- data.frame(
  paquete = todos,
  estado  = ifelse(vapply(todos, requireNamespace, logical(1), quietly = TRUE),
                   "OK", "NO INSTALADO"),
  version = vapply(todos, function(p) tryCatch(
    as.character(packageVersion(p)), error = function(e) "-"), ""),
  row.names = NULL
)
print(resultado, right = FALSE)

# Pruebas rápidas de funcionamiento
pruebas <- c(
  "sf (mapas)"       = tryCatch({ sf::sf_extSoftVersion(); TRUE },
                                error = function(e) FALSE),
  "DemoTools"        = tryCatch({
    # Población por grupos 0, 1-4, 5-9, ..., 100+ (datos de ejemplo de
    # DemoTools), desagregada a edades simples con el método de Sprague.
    Value <- DemoTools::pop5_mat[, 1]
    Value <- c(10000, 44170, Value[-1])
    Age   <- sort(c(1, seq(0, 100, by = 5)))
    DemoTools::graduate(Value, Age = Age, method = "sprague")
    TRUE }, error = function(e) FALSE),
  "ProjSubnacional"  = tryCatch({ suppressMessages(library(ProjSubnacional));
                                  TRUE }, error = function(e) FALSE)
)
cat("\nPruebas de funcionamiento:\n")
for (n in names(pruebas))
  cat(sprintf("  %-18s %s\n", n, ifelse(pruebas[[n]], "OK", "FALLÓ")))

if (all(resultado$estado == "OK") && all(pruebas)) {
  cat("\n*** ¡LISTO! Todo está instalado correctamente. ",
      "Puede cerrar este script. ***\n")
} else {
  cat("\n*** ATENCIÓN: algunos paquetes no se instalaron o fallaron. ***\n",
      "1) Vuelva a ejecutar el script completo (a veces basta con repetir).\n",
      "2) Si persiste, consulte SOLUCIÓN DE PROBLEMAS (final del archivo).\n",
      "3) Envíe al instructor una captura de esta tabla y de sessionInfo():\n")
  print(sessionInfo())
}

# =============================================================================
#  SOLUCIÓN DE PROBLEMAS
# =============================================================================
#
#  1) "API rate limit exceeded" / "HTTP error 403" (GitHub, PASO 4)
#     Demasiadas descargas desde la misma red. Opciones:
#       a) Espere 30-60 minutos y vuelva a ejecutar el script.
#       b) Si tiene cuenta en GitHub, cree un token (Settings > Developer
#          settings > Personal access tokens) y antes de ejecutar escriba:
#             Sys.setenv(GITHUB_PAT = "ghp_SU_TOKEN_AQUI")
#
#  2) "package 'xxx' is not available for this version of R"
#     El paquete no existe en el repositorio configurado. Avise al
#     instructor indicando el nombre del paquete.
#
#  3) "cannot open URL" / "Timeout of ... seconds was reached"
#     Problema de conexión. Verifique internet y vuelva a ejecutar.
#     Si está detrás de un proxy institucional, antes de ejecutar escriba:
#        Sys.setenv(http_proxy  = "http://usuario:clave@proxy:puerto",
#                   https_proxy = "http://usuario:clave@proxy:puerto")
#
#  4) "lock" / "00LOCK-xxx" / "cannot remove prior installation"
#     Una instalación anterior quedó interrumpida. Cierre RStudio, borre la
#     carpeta 00LOCK-xxx indicada en el mensaje (dentro de la biblioteca de
#     R; la ruta aparece con .libPaths()) y vuelva a ejecutar.
#
#  5) "namespace 'xxx' is already loaded, but >= y.z is required"
#     Reinicie R (menú Session > Restart R, o Ctrl/Cmd + Shift + F10) y
#     vuelva a ejecutar el script.
#
#  6) "xcrun: error: invalid active developer path" o se pide Xcode
#     Significa que R intentó compilar un paquete. Verifique que respondió
#     "no" a la pregunta de instalar desde fuente. Si aun así es necesario,
#     abra la aplicación Terminal y ejecute:
#        xcode-select --install
#     y luego vuelva a ejecutar el script.
#
#  7) "package 'xxx' was built for x86_64" / "incompatible architecture"
#     Instaló la versión de R equivocada para su procesador. Desinstale R e
#     instale la versión correcta (arm64 para M1/M2/M3/M4; x86_64 para Intel).
#
#  8) El paquete sf no carga ("GDAL" / "libproj" not found)
#     Reinstale sf en binario:
#        install.packages("sf", type = "binary")
# =============================================================================
