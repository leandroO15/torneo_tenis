library(shiny)
library(shinydashboard)
library(DT)
library(dplyr)
library(stringr)
library(shinyWidgets)
library(lubridate)
library(shinycssloaders)
library(reactable)

# Configuración de credenciales
ADMIN_USERS <- list(
  "carlos" = list(password = "carlos123", role = "admin", display_name = "Carlos (Administrador)"),
  "admin" = list(password = "admin2024", role = "admin", display_name = "Administrador")
)

# Funciones auxiliares
cargar_o_vaciar <- function(nombre_archivo, estructura) {
  if (file.exists(nombre_archivo)) readRDS(nombre_archivo) else estructura
}

parse_set <- function(set_str) {
  if (is.null(set_str) || set_str == "") return(c(NA, NA))
  partes <- str_split(set_str, "-", simplify = TRUE)
  if (length(partes) != 2) return(c(NA, NA))
  as.numeric(partes)
}

# UI con estética profesional
ui <- dashboardPage(
  skin = "green",
  
  dashboardHeader(
    title = "🏆 Torneo de Tenis Florida Club",
    titleWidth = 350,
    tags$li(class = "dropdown",
            uiOutput("user_info"))
  ),
  
  dashboardSidebar(
    width = 280,
    sidebarMenu(
      id = "sidebar_menu",
      menuItem("🏆 Tabla de Posiciones", tabName = "posiciones", icon = icon("trophy")),
      menuItem("📊 Resultados", tabName = "resultados", icon = icon("table")),
      menuItem("📅 Próximos Partidos", tabName = "proximos", icon = icon("calendar")),
      menuItem("👤 Historial de Jugador", tabName = "historial_jugador", icon = icon("user")),
      conditionalPanel(
        condition = "output.can_manage_results",
        menuItem("📝 Cargar Resultados", tabName = "resultados_admin", icon = icon("plus-circle"))
      ),
      conditionalPanel(
        condition = "output.can_manage_results",
        menuItem("📅 Programar Partidos", tabName = "admin", icon = icon("calendar-plus"))
      ),
      menuItem("🔐 Administrador", tabName = "login_admin", icon = icon("lock"))
    )
  ),
  
  dashboardBody(
    tags$head(
      tags$style(HTML("
        /* Estilo general */
        body {
          font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        
        /* Header personalizado */
        .skin-green .main-header .logo {
          background: linear-gradient(135deg, #2c7d3e, #4caf50) !important;
          color: white;
          font-weight: bold;
          font-size: 18px;
        }
        
        .skin-green .main-header .navbar {
          background: linear-gradient(135deg, #2c7d3e, #4caf50) !important;
        }
        
        .main-header .navbar .nav>li>a { 
          color: white !important; 
        }
        
        /* Fondo principal */
        .content-wrapper, .right-side {
          background: linear-gradient(135deg, #f0f8f0, #e8f5e9);
          min-height: 100vh;
        }
        
        /* Sidebar */
        .skin-green .main-sidebar {
          background: linear-gradient(180deg, #1e5e2a, #2c7d3e) !important;
        }
        
        .skin-green .sidebar-menu > li.active > a {
          background: rgba(255,255,255,0.2) !important;
          border-left: 4px solid #81c784;
          font-weight: bold;
        }
        
        .skin-green .sidebar-menu > li > a:hover {
          background: rgba(255,255,255,0.1) !important;
        }
        
        /* Estilos para el login */
        .login-input .form-control {
          border-radius: 20px !important;
          border: 2px solid rgba(255,255,255,0.3) !important;
          padding: 10px 15px !important;
          background: rgba(255,255,255,0.9) !important;
          color: #333 !important;
        }
        .login-input .form-control:focus {
          border-color: #81c784 !important;
          box-shadow: 0 0 0 0.2rem rgba(129, 199, 132, 0.25) !important;
          background: white !important;
        }
        .login-btn {
          border-radius: 20px !important;
          font-weight: bold !important;
          padding: 10px 25px !important;
          min-width: 120px !important;
        }
        
        /* Cajas y tarjetas */
        .box {
          border-radius: 12px;
          box-shadow: 0 4px 12px rgba(0,0,0,0.1);
          border: none;
          margin-bottom: 20px;
          overflow: hidden;
          transition: all 0.3s ease;
        }
        
        .box:hover {
          transform: translateY(-2px);
          box-shadow: 0 6px 20px rgba(0,0,0,0.15);
        }
        
        .box-header {
          background: linear-gradient(135deg, #2c7d3e, #4caf50);
          color: white;
          padding: 15px 20px;
        }
        
        .box-header .box-title {
          font-size: 18px;
          font-weight: 600;
        }
        
        .box-success {
          border-top: none;
        }
        
        .box-success .box-header {
          background: linear-gradient(135deg, #2c7d3e, #4caf50);
        }
        
        .box-info .box-header {
          background: linear-gradient(135deg, #1976d2, #2196f3);
        }
        
        .box-warning .box-header {
          background: linear-gradient(135deg, #f57c00, #ff9800);
        }
        
        .box-primary .box-header {
          background: linear-gradient(135deg, #1976d2, #2196f3);
        }
        
        /* Botones modernos */
        .btn {
          border-radius: 8px;
          font-weight: 500;
          padding: 10px 20px;
          border: none;
          transition: all 0.3s ease;
          box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        
        .btn:hover {
          transform: translateY(-2px);
          box-shadow: 0 4px 12px rgba(0,0,0,0.2);
        }
        
        .btn-success {
          background: linear-gradient(135deg, #2c7d3e, #4caf50);
          color: white;
        }
        
        .btn-success:hover {
          background: linear-gradient(135deg, #1e5e2a, #2c7d3e);
          color: white;
        }
        
        .btn-info {
          background: linear-gradient(135deg, #1976d2, #2196f3);
          color: white;
        }
        
        .btn-info:hover {
          background: linear-gradient(135deg, #1565c0, #1976d2);
          color: white;
        }
        
        .btn-warning {
          background: linear-gradient(135deg, #f57c00, #ff9800);
          color: white;
        }
        
        .btn-warning:hover {
          background: linear-gradient(135deg, #ef6c00, #f57c00);
          color: white;
        }
        
        .btn-primary {
          background: linear-gradient(135deg, #1976d2, #2196f3);
          color: white;
        }
        
        .btn-primary:hover {
          background: linear-gradient(135deg, #1565c0, #1976d2);
          color: white;
        }
        
        .btn-default {
          background: linear-gradient(135deg, #757575, #9e9e9e);
          color: white;
        }
        
        .btn-danger {
          background: linear-gradient(135deg, #d32f2f, #f44336);
          color: white;
        }
        
        .btn-danger:hover {
          background: linear-gradient(135deg, #c62828, #d32f2f);
          color: white;
        }
        
        .btn-block {
          margin-bottom: 10px;
        }
        
        /* Botones pequeños para acciones */
        .btn-xs {
          padding: 2px 5px !important;
          font-size: 11px !important;
          line-height: 1.5 !important;
          border-radius: 3px !important;
          margin: 1px !important;
        }
        
        /* Value boxes */
        .small-box {
          border-radius: 12px;
          box-shadow: 0 4px 12px rgba(0,0,0,0.1);
          overflow: hidden;
          transition: all 0.3s ease;
        }
        
        .small-box:hover {
          transform: translateY(-2px);
          box-shadow: 0 6px 20px rgba(0,0,0,0.15);
        }
        
        .small-box .inner {
          padding: 20px;
        }
        
        .small-box h3 {
          font-size: 2.2em;
          font-weight: bold;
          margin: 0;
        }
        
        .small-box p {
          font-size: 1em;
          margin: 5px 0 0 0;
        }
        
        .bg-green {
          background: linear-gradient(135deg, #2c7d3e, #4caf50) !important;
        }
        
        .bg-aqua {
          background: linear-gradient(135deg, #00acc1, #26c6da) !important;
        }
        
        .bg-yellow {
          background: linear-gradient(135deg, #ffa000, #ffb300) !important;
        }
        
        .bg-blue {
          background: linear-gradient(135deg, #1976d2, #2196f3) !important;
        }
        
        /* Inputs mejorados */
        .form-control {
          border-radius: 8px;
          border: 2px solid #e0e0e0;
          padding: 10px 15px;
          transition: all 0.3s ease;
        }
        
        .form-control:focus {
          border-color: #4caf50;
          box-shadow: 0 0 0 0.2rem rgba(76, 175, 80, 0.25);
        }
        
        /* Jugador clickeable */
        .jugador-clickeable {
          color: #2c7d3e !important;
          font-weight: bold !important;
          cursor: pointer !important;
          text-decoration: underline !important;
          transition: all 0.3s ease;
        }
        .jugador-clickeable:hover {
          color: #1e5e2a !important;
          background-color: rgba(76, 175, 80, 0.1) !important;
          transform: scale(1.05);
        }
        
        /* Alertas personalizadas */
        .alert {
          border-radius: 8px;
          border: none;
          padding: 15px 20px;
          margin: 15px 0;
        }
        .alert-info {
          background: linear-gradient(135deg, #e3f2fd, #bbdefb);
          color: #0d47a1;
          border-left: 4px solid #2196f3;
        }
        .alert-success {
          background: linear-gradient(135deg, #e8f5e9, #c8e6c9);
          color: #1e5e2a;
          border-left: 4px solid #2c7d3e;
        }
        .alert-warning {
          background: linear-gradient(135deg, #fff8e1, #ffecb3);
          color: #e65100;
          border-left: 4px solid #ff9800;
        }
        
        /* Reactable personalizado */
        .reactable {
          border-radius: 8px;
          overflow: hidden;
          box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        
        /* Badges y etiquetas */
        .badge {
          padding: 6px 12px;
          border-radius: 20px;
          font-weight: 500;
          font-size: 0.85em;
        }
        
        .badge-success {
          background: linear-gradient(135deg, #2c7d3e, #4caf50);
          color: white;
        }
        
        .badge-warning {
          background: linear-gradient(135deg, #f57c00, #ff9800);
          color: white;
        }
        
        .badge-danger {
          background: linear-gradient(135deg, #d32f2f, #f44336);
          color: white;
        }
        
        .badge-info {
          background: linear-gradient(135deg, #1976d2, #2196f3);
          color: white;
        }
        
        /* Animaciones */
        @keyframes fadeIn {
          from { opacity: 0; transform: translateY(20px); }
          to { opacity: 1; transform: translateY(0); }
        }
        
        .box, .small-box {
          animation: fadeIn 0.5s ease-out;
        }
        
        /* Responsive */
        @media (max-width: 768px) {
          .content-wrapper {
            padding: 10px;
          }
          
          .box {
            margin: 10px 0;
          }
          
          .btn {
            padding: 8px 16px;
            font-size: 0.9em;
          }
        }
        
        /* Mejoras para selectInput */
        .selectize-control {
          margin-bottom: 10px;
        }
        .selectize-input {
          border-radius: 8px;
          border: 2px solid #e0e0e0;
          padding: 10px 15px;
          font-size: 14px;
        }
        .selectize-input.focus {
          border-color: #4caf50;
          box-shadow: 0 0 0 0.2rem rgba(76, 175, 80, 0.25);
        }
      "))
    ),
    
    tabItems(
      # Tabla de Posiciones
      tabItem(tabName = "posiciones",
        fluidRow(
          box(
            title = "🏆 Tabla de Posiciones - Temporada 2024", 
            status = "success", 
            solidHeader = TRUE, 
            width = 12,
            withSpinner(reactableOutput("tabla_posiciones"), 
                       type = 6, 
                       color = "#4caf50")
          )
        ),
        fluidRow(
          valueBoxOutput("total_partidos_jugados", width = 3),
          valueBoxOutput("total_sets_disputados", width = 3),
          valueBoxOutput("total_games_disputados", width = 3),
          valueBoxOutput("lider_torneo", width = 3)
        ),
        fluidRow(
          box(
            title = "📅 Próximos Partidos",
            status = "info",
            solidHeader = TRUE,
            width = 6,
            tableOutput("proximos_mini")
          ),
          box(
            title = "⚡ Acciones Rápidas",
            status = "warning",
            solidHeader = TRUE,
            width = 6,
            div(
              actionButton("goToMatches", "📊 Ver Resultados", 
                           icon = icon("table"), 
                           class = "btn-info btn-block"),
              style = "margin-bottom: 10px;"
            ),
            div(
              actionButton("goToProximos", "📅 Próximos Partidos", 
                           icon = icon("calendar"), 
                           class = "btn-warning btn-block")
            )
          )
        )
      ),
      
      # Historial de Jugador (Nueva pestaña)
      tabItem(tabName = "historial_jugador",
        fluidRow(
          box(
            title = "👤 Historial de Jugador",
            status = "info",
            solidHeader = TRUE,
            width = 12,
            div(
              class = "row",
              div(
                class = "col-md-6",
                selectInput("jugador_historial", "Selecciona un jugador:", choices = NULL)
              ),
              div(
                class = "col-md-6",
                div(
                  style = "margin-top: 25px;",
                  actionButton("ver_historial", "🔍 Ver Historial", class = "btn-info")
                )
              )
            )
          )
        ),
        conditionalPanel(
          condition = "input.ver_historial > 0 && input.jugador_historial != ''",
          fluidRow(
            box(
              title = textOutput("titulo_historial_jugador"),
              status = "success", 
              solidHeader = TRUE, 
              width = 12,
              withSpinner(DTOutput("tabla_historial_jugador"), 
                         type = 6, 
                         color = "#4caf50")
            )
          ),
          fluidRow(
            valueBoxOutput("partidos_jugados_jugador", width = 3),
            valueBoxOutput("partidos_ganados_jugador", width = 3),
            valueBoxOutput("sets_ganados_jugador", width = 3),
            valueBoxOutput("efectividad_jugador", width = 3)
          )
        )
      ),
      
      # Resultados - IDÉNTICO A PARTIDOS
      tabItem(tabName = "resultados",
        fluidRow(
          box(
            title = "📅 Gestión de Partidos",
            status = "success",
            solidHeader = TRUE,
            width = 12,
            div(
              class = "row",
              div(
                class = "col-md-8",
                h4("Gestiona los partidos programados y resultados", style = "color: #2c7d3e; margin-top: 0;")
              ),
              div(
                class = "col-md-4",
                div(
                  style = "display: flex; justify-content: flex-end;",
                  selectInput("matchDateFilter", "📅 Filtrar por fecha:",
                              choices = c("Todas las fechas" = "all"),
                              selected = "all",
                              width = "100%")
                )
              )
            ),
            div(
              style = "margin-top: 20px;",
              withSpinner(DTOutput("tabla_resultados"), 
                         type = 6, 
                         color = "#2196f3")
            ),
            conditionalPanel(
              condition = "output.can_manage_results",
              div(
                style = "margin-top: 20px; text-align: right;",
                actionButton("newMatchBtn", "➕ Nuevo Partido", 
                             icon = icon("plus"), 
                             class = "btn-success")
              )
            )
          )
        )
      ),
      
      # Próximos Partidos
      tabItem(tabName = "proximos",
        fluidRow(
          box(
            title = "📅 Próximos Partidos Programados", 
            status = "info", 
            solidHeader = TRUE, 
            width = 12,
            withSpinner(DTOutput("tabla_proximos"), 
                       type = 6, 
                       color = "#00bcd4")
          )
        )
      ),
      
      # Login de Administrador (Nueva pestaña)
      tabItem(tabName = "login_admin",
        fluidRow(
          box(
            title = "🔐 Acceso Administrador",
            status = "warning",
            solidHeader = TRUE,
            width = 6,
            offset = 3,
            conditionalPanel(
              condition = "!output.logged_in",
              div(
                style = "padding: 20px;",
                div(
                  style = "text-align: center; margin-bottom: 20px;",
                  icon("user-shield", style = "font-size: 48px; color: #ff9800;")
                ),
                div(style = "margin-bottom: 20px;",
                    div(class = "login-input",
                        textInput("username", "👤 Usuario", placeholder = "Ingresa tu usuario"))),
                div(style = "margin-bottom: 20px;",
                    div(class = "login-input",
                        passwordInput("password", "🔒 Contraseña", placeholder = "Ingresa tu contraseña"))),
                div(style = "text-align: center;",
                    actionButton("login", "🚀 Ingresar", 
                                class = "btn-success login-btn")),
                br(),
                div(style = "color: #666; font-size: 12px; text-align: center; margin-top: 10px;",
                    "🔑 Solo para administradores autorizados")
              )
            ),
            conditionalPanel(
              condition = "output.logged_in",
              div(
                style = "padding: 20px; text-align: center;",
                div(
                  style = "margin-bottom: 20px;",
                  icon("check-circle", style = "font-size: 48px; color: #4caf50;")
                ),
                h3("¡Sesión iniciada correctamente!", style = "color: #2c7d3e; margin-bottom: 20px;"),
                uiOutput("welcome_message_admin"),
                br(),
                div(style = "margin-top: 20px;",
                    actionButton("logout", "🚪 Cerrar Sesión", 
                                class = "btn-warning login-btn"))
              )
            )
          )
        )
      ),
      
      # Cargar Resultados (solo para admins)
      tabItem(tabName = "resultados_admin",
        conditionalPanel(
          condition = "output.can_manage_results",
          fluidRow(
            box(
              title = "➕ Cargar Resultado de Partido",
              status = "success",
              solidHeader = TRUE,
              width = 12,
              div(
                class = "alert alert-success",
                icon("check-circle"), 
                " Completa todos los campos para registrar el resultado del partido."
              ),
              div(
                class = "row",
                div(
                  class = "col-md-6",
                  selectInput("jugador1", "🎾 Jugador 1:", 
                              choices = NULL,
                              selected = NULL)
                ),
                div(
                  class = "col-md-6",
                  selectInput("jugador2", "🎾 Jugador 2:", 
                              choices = NULL,
                              selected = NULL)
                )
              ),
              div(
                class = "row",
                div(
                  class = "col-md-6",
                  dateInput("fecha_partido", "📅 Fecha del Partido:", 
                            value = Sys.Date(),
                            format = "dd/mm/yyyy",
                            language = "es")
                )
              ),
              div(
                class = "well",
                style = "background: linear-gradient(135deg, #f8f9fa, #e9ecef); border: none; border-radius: 12px; padding: 20px; margin-top: 20px;",
                h4("🏆 Resultado del Partido", style = "color: #2c7d3e; margin-top: 0;"),
                p("Formato: games ganados - games perdidos (ej: 6-4)", 
                  style = "color: #666; margin-bottom: 15px;"),
                fluidRow(
                  column(4, textInput("set1", "🎾 Set 1", placeholder = "6-4")),
                  column(4, textInput("set2", "🎾 Set 2", placeholder = "6-2")),
                  column(4, textInput("set3", "🎾 Set 3 (opcional)", placeholder = "7-5"))
                )
              ),
              div(style = "text-align: center; margin-top: 30px;",
                  actionButton("guardar_resultado", "💾 Guardar Resultado", 
                              icon = icon("save"),
                              class = "btn-success"))
            )
          )
        ),
        conditionalPanel(
          condition = "!output.can_manage_results",
          fluidRow(
            box(
              title = "🔐 Acceso Restringido", 
              status = "warning", 
              solidHeader = TRUE, 
              width = 12,
              div(
                style = "text-align: center; padding: 40px;",
                icon("shield-alt", style = "font-size: 48px; color: #ff9800; margin-bottom: 20px;"),
                h3("Solo los administradores pueden cargar resultados", 
                   style = "color: #f57c00; margin-bottom: 20px;"),
                p("Contacta a Carlos o al administrador para registrar resultados", 
                  style = "color: #666; font-size: 16px;")
              )
            )
          )
        )
      ),
      
      # Programar Partidos (solo para admins)
      tabItem(tabName = "admin",
        conditionalPanel(
          condition = "output.can_manage_results",
          fluidRow(
            column(6,
              box(
                title = "👥 Gestión de Jugadores", 
                status = "success", 
                solidHeader = TRUE, 
                width = NULL,
                textInput("nombre_jugador", "👤 Nombre del Jugador", 
                         placeholder = "Ingresa el nombre completo"),
                textInput("email_jugador", "📧 Email (opcional)", 
                         placeholder = "correo@ejemplo.com"),
                div(style = "text-align: center; margin: 20px 0;",
                    actionButton("agregar_jugador", "➕ Agregar Jugador", 
                                class = "btn-success")),
                withSpinner(DTOutput("lista_jugadores"), 
                           type = 6, 
                           color = "#4caf50")
              )
            ),
            column(6,
              box(
                title = "📅 Programar Nuevos Partidos", 
                status = "warning", 
                solidHeader = TRUE, 
                width = NULL,
                fluidRow(
                  column(6, selectInput("prog_jugador1", "🎾 Jugador 1", choices = NULL)),
                  column(6, selectInput("prog_jugador2", "🎾 Jugador 2", choices = NULL))
                ),
                fluidRow(
                  column(6, dateInput("prog_fecha", "📅 Fecha", 
                                     min = Sys.Date(),
                                     format = "dd/mm/yyyy",
                                     language = "es")),
                  column(6, selectInput("prog_hora", "⏰ Hora", 
                    choices = c("09:00", "10:30", "12:00", "13:30", "15:00", "16:30", "18:00", "19:30")))
                ),
                div(style = "text-align: center; margin: 20px 0;",
                    actionButton("programar_partido", "📅 Programar Partido", 
                                class = "btn-warning"))
              )
            )
          ),
          fluidRow(
            box(
              title = "📋 Gestión de Resultados", 
              status = "info", 
              solidHeader = TRUE, 
              width = 12,
              withSpinner(DTOutput("gestion_resultados"), 
                         type = 6, 
                         color = "#00bcd4")
            )
          ),
          fluidRow(
            box(
              title = "📋 Partidos Programados", 
              status = "info", 
              solidHeader = TRUE, 
              width = 12,
              withSpinner(DTOutput("partidos_programados_admin"), 
                         type = 6, 
                         color = "#00bcd4")
            )
          )
        ),
        conditionalPanel(
          condition = "!output.can_manage_results",
          fluidRow(
            box(
              title = "🔐 Acceso de Administrador Requerido", 
              status = "warning", 
              solidHeader = TRUE, 
              width = 12,
              div(
                style = "text-align: center; padding: 40px;",
                icon("user-shield", style = "font-size: 48px; color: #ff9800; margin-bottom: 20px;"),
                h3("Panel de administración", 
                   style = "color: #f57c00; margin-bottom: 20px;"),
                p("Solo los administradores pueden acceder a esta sección", 
                  style = "color: #666; font-size: 16px;")
              )
            )
          )
        )
      )
    )
  )
)

# Server mejorado
server <- function(input, output, session) {
  # Archivos de datos
  jugadores_path <- "jugadores.rds"
  resultados_path <- "resultados.rds"
  proximos_path <- "proximos_partidos.rds"
  
  # Estados reactivos
  current_user <- reactiveVal(NULL)
  user_role <- reactiveVal("player")
  can_manage_results <- reactiveVal(FALSE)
  jugador_seleccionado <- reactiveVal(NULL)
  
  jugadores <- reactiveVal(cargar_o_vaciar(jugadores_path, 
    data.frame(nombre = character(), email = character(), stringsAsFactors = FALSE)))
  
  resultados <- reactiveVal(cargar_o_vaciar(resultados_path, 
    data.frame(jugador1 = character(), jugador2 = character(),
               set1 = character(), set2 = character(), set3 = character(),
               fecha = as.Date(character()), stringsAsFactors = FALSE)))
  
  proximos_partidos <- reactiveVal(cargar_o_vaciar(proximos_path,
    data.frame(jugador1 = character(), jugador2 = character(), 
               fecha = as.Date(character()), hora = character(), stringsAsFactors = FALSE)))
  
  # Outputs de estado
  output$logged_in <- reactive({ !is.null(current_user()) })
  output$can_manage_results <- reactive({ can_manage_results() })
  outputOptions(output, "logged_in", suspendWhenHidden = FALSE)
  outputOptions(output, "can_manage_results", suspendWhenHidden = FALSE)
  
  output$user_info <- renderUI({
    if (!is.null(current_user())) {
      role_icon <- if (user_role() == "admin") "👑" else "👤"
      tags$span(paste(role_icon, current_user()), 
               style = "color: white; margin-right: 20px; font-weight: bold;")
    }
  })
  
  output$welcome_message <- renderUI({
    if (!is.null(current_user())) {
      role_text <- if (user_role() == "admin") "Administrador" else "Jugador"
      div(
        style = "color: white; text-align: center;",
        h5(paste("¡Hola,", strsplit(current_user(), " ")[[1]][1], "!"), 
           style = "margin: 0; font-weight: bold;"),
        p(paste("🎾", role_text), 
          style = "margin: 5px 0 0 0; font-size: 12px; opacity: 0.9;")
      )
    }
  })
  
  output$welcome_message_admin <- renderUI({
    if (!is.null(current_user())) {
      div(
        style = "color: #2c7d3e; text-align: center;",
        h4(paste("¡Bienvenido,", current_user(), "!"), 
           style = "margin: 0; font-weight: bold;"),
        p("Ahora tienes acceso a todas las funciones administrativas", 
          style = "margin: 10px 0 0 0; font-size: 14px;")
      )
    }
  })
  
  # Login/Logout
  observeEvent(input$login, {
    req(input$username, input$password)
    
    username <- trimws(input$username)
    password <- trimws(input$password)
    
    # Solo verificar administradores
    if (username %in% names(ADMIN_USERS)) {
      admin_info <- ADMIN_USERS[[username]]
      if (password == admin_info$password) {
        current_user(admin_info$display_name)
        user_role("admin")
        can_manage_results(TRUE)
        showNotification(
          paste("🎉 Bienvenido", admin_info$display_name), 
          type = "message",
          duration = 5
        )
      } else {
        showNotification("❌ Contraseña incorrecta", type = "error")
        return()
      }
    } else {
      showNotification("❌ Usuario no autorizado", type = "error")
      return()
    }
    
    updateTextInput(session, "username", value = "")
    updateTextInput(session, "password", value = "")
  })
  
  observeEvent(input$logout, {
    user_name <- strsplit(current_user(), " ")[[1]][1]
    current_user(NULL)
    user_role("player")
    can_manage_results(FALSE)
    showNotification(paste("👋 Hasta luego,", user_name), type = "message", duration = 3)
  })
  
  # Actualizar choices de jugadores
  observe({
    choices <- jugadores()$nombre
    updateSelectInput(session, "jugador1", choices = choices)
    updateSelectInput(session, "jugador2", choices = choices)
    updateSelectInput(session, "prog_jugador1", choices = choices)
    updateSelectInput(session, "prog_jugador2", choices = choices)
    updateSelectInput(session, "jugador_historial", choices = choices)
  })
  
  # Actualizar filtro de fechas
  observe({
    fechas_disponibles <- unique(resultados()$fecha)
    if (length(fechas_disponibles) > 0) {
      fechas_choices <- c("Todas las fechas" = "all")
      for (fecha in sort(fechas_disponibles, decreasing = TRUE)) {
        fecha_formateada <- format(as.Date(fecha), "%d %B %Y")
        fechas_choices[fecha_formateada] <- as.character(fecha)
      }
      updateSelectInput(session, "matchDateFilter", choices = fechas_choices)
    }
  })
  
  # Navegación entre páginas
  observeEvent(input$goToMatches, {
    updateTabItems(session, "sidebar_menu", "resultados")
  })
  
  observeEvent(input$goToProximos, {
    updateTabItems(session, "sidebar_menu", "proximos")
  })
  
  observeEvent(input$newMatchBtn, {
    updateTabItems(session, "sidebar_menu", "resultados_admin")
  })
  
  # Redirigir a historial de jugador al hacer clic en la tabla de posiciones
  observeEvent(input$jugador_click_posiciones, {
    updateSelectInput(session, "jugador_historial", selected = input$jugador_click_posiciones)
    updateTabItems(session, "sidebar_menu", "historial_jugador")
    # Simular clic en el botón para mostrar el historial
    shinyjs::delay(300, {
      shinyjs::click("ver_historial")
    })
  })
  
  # Agregar jugador (solo admins)
  observeEvent(input$agregar_jugador, {
    req(can_manage_results(), input$nombre_jugador != "")
    
    nombre <- trimws(input$nombre_jugador)
    
    if (!(nombre %in% jugadores()$nombre)) {
      nuevo_jugador <- data.frame(
        nombre = nombre,
        email = ifelse(is.null(input$email_jugador) || input$email_jugador == "", "", trimws(input$email_jugador)),
        stringsAsFactors = FALSE
      )
      nuevos <- bind_rows(jugadores(), nuevo_jugador)
      jugadores(nuevos)
      saveRDS(nuevos, jugadores_path)
      
      updateTextInput(session, "nombre_jugador", value = "")
      updateTextInput(session, "email_jugador", value = "")
      showNotification("✅ Jugador agregado exitosamente", type = "message")
    } else {
      showNotification("⚠️ El jugador ya existe", type = "warning")
    }
  })
  
  # Guardar resultado (solo admins)
  observeEvent(input$guardar_resultado, {
    req(can_manage_results(), input$jugador1, input$jugador2, input$jugador1 != input$jugador2)
    
    if (input$jugador1 == input$jugador2) {
      showNotification("❌ Los jugadores deben ser diferentes", type = "error")
      return()
    }
    
    if (input$set1 == "" || input$set2 == "") {
      showNotification("❌ Los primeros dos sets son obligatorios", type = "error")
      return()
    }
    
    nuevo_resultado <- data.frame(
      jugador1 = input$jugador1,
      jugador2 = input$jugador2,
      set1 = trimws(input$set1),
      set2 = trimws(input$set2),
      set3 = ifelse(is.null(input$set3) || input$set3 == "", "", trimws(input$set3)),
      fecha = input$fecha_partido,
      stringsAsFactors = FALSE
    )
    
    nuevos_resultados <- bind_rows(resultados(), nuevo_resultado)
    resultados(nuevos_resultados)
    saveRDS(nuevos_resultados, resultados_path)
    
    # Limpiar campos
    updateTextInput(session, "set1", value = "")
    updateTextInput(session, "set2", value = "")
    updateTextInput(session, "set3", value = "")
    updateSelectInput(session, "jugador1", selected = "")
    updateSelectInput(session, "jugador2", selected = "")
    
    showNotification("🎾 Resultado guardado exitosamente", type = "message", duration = 5)
  })
  
  # Programar partido (solo admins)
  observeEvent(input$programar_partido, {
    req(can_manage_results(), input$prog_jugador1, input$prog_jugador2, 
        input$prog_jugador1 != input$prog_jugador2)
    
    nuevo_partido <- data.frame(
      jugador1 = input$prog_jugador1,
      jugador2 = input$prog_jugador2,
      fecha = input$prog_fecha,
      hora = input$prog_hora,
      stringsAsFactors = FALSE
    )
    
    nuevos_proximos <- bind_rows(proximos_partidos(), nuevo_partido)
    proximos_partidos(nuevos_proximos)
    saveRDS(nuevos_proximos, proximos_path)
    
    showNotification("📅 Partido programado exitosamente", type = "message")
  })
  
  # Función para calcular estadísticas con reglas especiales del tercer set
  calcular_estadisticas <- function() {
    if (nrow(resultados()) == 0) {
      return(list(
        partidos_jugados = 0,
        sets_disputados = 0,
        games_disputados = 0,
        resumen_jugadores = data.frame()
      ))
    }
    
    partidos <- resultados()
    jugadores_all <- unique(c(partidos$jugador1, partidos$jugador2))
    
    resumen <- data.frame(
      Jugador = jugadores_all,
      PG = 0,
      PJ = 0,
      SG = 0,
      SP = 0,
      GG = 0,
      GP = 0,
      stringsAsFactors = FALSE
    )
    
    total_sets_disputados <- 0
    total_games_disputados <- 0
    
    for (i in 1:nrow(partidos)) {
      fila <- partidos[i, ]
      
      # Extraer los resultados de los sets de manera segura
      set1 <- tryCatch({
        if (is.null(fila$set1) || fila$set1 == "") c(NA, NA) else {
          partes <- str_split(fila$set1, "-", simplify = TRUE)
          if (length(partes) != 2) c(NA, NA) else as.numeric(partes)
        }
      }, error = function(e) c(NA, NA))
      
      set2 <- tryCatch({
        if (is.null(fila$set2) || fila$set2 == "") c(NA, NA) else {
          partes <- str_split(fila$set2, "-", simplify = TRUE)
          if (length(partes) != 2) c(NA, NA) else as.numeric(partes)
        }
      }, error = function(e) c(NA, NA))
      
      set3 <- tryCatch({
        if (is.null(fila$set3) || fila$set3 == "") c(NA, NA) else {
          partes <- str_split(fila$set3, "-", simplify = TRUE)
          if (length(partes) != 2) c(NA, NA) else as.numeric(partes)
        }
      }, error = function(e) c(NA, NA))
      
      sets <- list(set1, set2, set3)
      
      # Contar sets válidos
      sets_validos <- sum(!sapply(sets, function(x) any(is.na(x))))
      total_sets_disputados <- total_sets_disputados + sets_validos
      
      sets_j1 <- sum(sapply(sets, function(x) if (!any(is.na(x))) x[1] > x[2] else FALSE))
      sets_j2 <- sum(sapply(sets, function(x) if (!any(is.na(x))) x[2] > x[1] else FALSE))
      
      # Actualizar partidos
      resumen[resumen$Jugador == fila$jugador1, "PJ"] <- 
        resumen[resumen$Jugador == fila$jugador1, "PJ"] + 1
      resumen[resumen$Jugador == fila$jugador2, "PJ"] <- 
        resumen[resumen$Jugador == fila$jugador2, "PJ"] + 1
      
      if (sets_j1 > sets_j2) {
        resumen[resumen$Jugador == fila$jugador1, "PG"] <- 
          resumen[resumen$Jugador == fila$jugador1, "PG"] + 1
      } else if (sets_j2 > sets_j1) {
        resumen[resumen$Jugador == fila$jugador2, "PG"] <- 
          resumen[resumen$Jugador == fila$jugador2, "PG"] + 1
      }
      
      # Actualizar sets
      resumen[resumen$Jugador == fila$jugador1, "SG"] <- 
        resumen[resumen$Jugador == fila$jugador1, "SG"] + sets_j1
      resumen[resumen$Jugador == fila$jugador2, "SG"] <- 
        resumen[resumen$Jugador == fila$jugador2, "SG"] + sets_j2
      
      resumen[resumen$Jugador == fila$jugador1, "SP"] <- 
        resumen[resumen$Jugador == fila$jugador1, "SP"] + sets_j2
      resumen[resumen$Jugador == fila$jugador2, "SP"] <- 
        resumen[resumen$Jugador == fila$jugador2, "SP"] + sets_j1
      
      # Actualizar games con regla especial del tercer set
      for (j in 1:length(sets)) {
        if (!any(is.na(sets[[j]]))) {
          if (j == 3) {
            # Tercer set: solo suma 1 game al ganador
            if (sets[[j]][1] > sets[[j]][2]) {
              resumen[resumen$Jugador == fila$jugador1, "GG"] <- 
                resumen[resumen$Jugador == fila$jugador1, "GG"] + 1
              total_games_disputados <- total_games_disputados + 1
            } else {
              resumen[resumen$Jugador == fila$jugador2, "GG"] <- 
                resumen[resumen$Jugador == fila$jugador2, "GG"] + 1
              total_games_disputados <- total_games_disputados + 1
            }
          } else {
            # Sets 1 y 2: suma todos los games
            resumen[resumen$Jugador == fila$jugador1, "GG"] <- 
              resumen[resumen$Jugador == fila$jugador1, "GG"] + sets[[j]][1]
            resumen[resumen$Jugador == fila$jugador2, "GG"] <- 
              resumen[resumen$Jugador == fila$jugador2, "GG"] + sets[[j]][2]
            resumen[resumen$Jugador == fila$jugador1, "GP"] <- 
              resumen[resumen$Jugador == fila$jugador1, "GP"] + sets[[j]][2]
            resumen[resumen$Jugador == fila$jugador2, "GP"] <- 
              resumen[resumen$Jugador == fila$jugador2, "GP"] + sets[[j]][1]
            total_games_disputados <- total_games_disputados + sets[[j]][1] + sets[[j]][2]
          }
        }
      }
    }
    
    resumen <- resumen %>%
      mutate(
        Efectividad = round(PG / pmax(PJ, 1) * 100, 1),
        `Dif Sets` = SG - SP,
        `Dif Games` = GG - GP
      ) %>%
      arrange(desc(PG), desc(`Dif Sets`), desc(`Dif Games`)) %>%
      mutate(Pos = row_number()) %>%
      select(Pos, Jugador, PJ, PG, SG, SP, GG, GP, `Dif Sets`, `Dif Games`, Efectividad)
    
    return(list(
      partidos_jugados = nrow(partidos),
      sets_disputados = total_sets_disputados,
      games_disputados = total_games_disputados,
      resumen_jugadores = resumen
    ))
  }
  
  # Tabla de posiciones con reactable y jugadores clickeables
  output$tabla_posiciones <- renderReactable({
    stats <- calcular_estadisticas()
    
    if (nrow(stats$resumen_jugadores) == 0) {
      return(reactable(
        data.frame(Mensaje = "🎾 No hay resultados cargados aún. ¡Comienza a jugar!"), 
        columns = list(
          Mensaje = colDef(name = "", align = "center")
        )
      ))
    }
    
    resumen <- stats$resumen_jugadores
    
    reactable(
      resumen,
      onClick = JS("function(rowInfo, colInfo) {
        if (colInfo.id === 'Jugador') {
          Shiny.setInputValue('jugador_click_posiciones', rowInfo.row.Jugador);
        }
      }"),
      columns = list(
        Pos = colDef(
          name = "Pos", 
          width = 60,
          align = "center",
          cell = function(value) {
            medal <- if (value == 1) "🥇" else if (value == 2) "🥈" else if (value == 3) "🥉" else ""
            paste(value, medal)
          }
        ),
        Jugador = colDef(
          name = "Jugador", 
          minWidth = 150, 
          style = list(fontWeight = "500", color = "#2c7d3e", cursor = "pointer"),
          cell = function(value) {
            div(
              style = list(
                textDecoration = "underline",
                fontWeight = "bold"
              ),
              value
            )
          }
        ),
        PJ = colDef(name = "PJ", align = "center", width = 60),
        PG = colDef(
          name = "PG", 
          align = "center", 
          width = 60,
          style = function(value) {
            list(color = "#2c7d3e", fontWeight = "bold")
          }
        ),
        SG = colDef(name = "SG", align = "center", width = 60),
        SP = colDef(name = "SP", align = "center", width = 60),
        GG = colDef(name = "GG", align = "center", width = 70),
        GP = colDef(name = "GP", align = "center", width = 70),
        `Dif Sets` = colDef(
          name = "Dif Sets", 
          align = "center", 
          width = 80,
          style = function(value) {
            color <- if (value > 0) "#2c7d3e" else if (value < 0) "#d32f2f" else "#666"
            list(color = color, fontWeight = "bold")
          }
        ),
        `Dif Games` = colDef(
          name = "Dif Games", 
          align = "center", 
          width = 90,
          style = function(value) {
            color <- if (value > 0) "#2c7d3e" else if (value < 0) "#d32f2f" else "#666"
            list(color = color, fontWeight = "bold")
          }
        ),
        Efectividad = colDef(
          name = "Efectividad",
          align = "center",
          width = 100,
          cell = function(value) {
            color <- if (value >= 70) {
              "#2c7d3e"
            } else if (value >= 50) {
              "#ff9800"
            } else {
              "#d32f2f"
            }
            div(
              style = list(
                background = color,
                color = "white",
                padding = "4px 8px",
                borderRadius = "12px",
                display = "inline-block",
                fontSize = "0.85em",
                fontWeight = "500"
              ),
              paste0(value, "%")
            )
          }
        )
      ),
      striped = TRUE,
      highlight = TRUE,
      bordered = TRUE,
      defaultPageSize = 10,
      rowStyle = function(index) {
        if (index <= 3) {
          list(background = "rgba(255, 248, 225, 0.7)", fontWeight = "500")
        }
      },
      theme = reactableTheme(
        headerStyle = list(
          background = "#2c7d3e",
          color = "white",
          fontWeight = "600"
        )
      )
    )
  })
  
  # Tabla de resultados idéntica a partidos
  output$tabla_resultados <- renderDT({
    if (nrow(resultados()) == 0) {
      return(datatable(data.frame(Mensaje = "No hay resultados cargados aún"), 
                      options = list(dom = "t")))
    }
    
    filtered_matches <- resultados()
    
    if (input$matchDateFilter != "all") {
      filtered_matches <- filtered_matches %>%
        filter(fecha == input$matchDateFilter)
    }
    
    datos <- filtered_matches %>%
      arrange(desc(fecha)) %>%
      mutate(
        match = paste("🎾", jugador1, "vs", jugador2),
        match_date = format(fecha, "%d/%m/%Y"),
        status_label = "✅ Finalizado"
      )
    
    # Agregar resultados para partidos completados
    datos$result <- sapply(1:nrow(datos), function(i) {
      fila <- datos[i, ]
      
      # Extraer los resultados de los sets de manera segura
      set1 <- tryCatch({
        if (is.null(fila$set1) || fila$set1 == "") c(NA, NA) else {
          partes <- str_split(fila$set1, "-", simplify = TRUE)
          if (length(partes) != 2) c(NA, NA) else as.numeric(partes)
        }
      }, error = function(e) c(NA, NA))
      
      set2 <- tryCatch({
        if (is.null(fila$set2) || fila$set2 == "") c(NA, NA) else {
          partes <- str_split(fila$set2, "-", simplify = TRUE)
          if (length(partes) != 2) c(NA, NA) else as.numeric(partes)
        }
      }, error = function(e) c(NA, NA))
      
      set3 <- tryCatch({
        if (is.null(fila$set3) || fila$set3 == "") c(NA, NA) else {
          partes <- str_split(fila$set3, "-", simplify = TRUE)
          if (length(partes) != 2) c(NA, NA) else as.numeric(partes)
        }
      }, error = function(e) c(NA, NA))
      
      sets <- list(set1, set2, set3)
      
      sets_str <- sapply(1:length(sets), function(j) {
        if (!any(is.na(sets[[j]]))) {
          paste0(sets[[j]][1], "-", sets[[j]][2])
        } else {
          NULL
        }
      })
      sets_str <- sets_str[!sapply(sets_str, is.null)]
      
      # Determinar ganador
      sets_j1 <- sum(sapply(sets, function(x) if (!any(is.na(x))) x[1] > x[2] else FALSE))
      sets_j2 <- sum(sapply(sets, function(x) if (!any(is.na(x))) x[2] > x[1] else FALSE))
      
      winner <- if (sets_j1 > sets_j2) {
        fila$jugador1
      } else {
        fila$jugador2
      }
      
      paste0("🏆 ", paste(sets_str, collapse = ", "), " (Ganador: ", winner, ")")
    })
    
    datos_finales <- datos %>%
      select(match, match_date, status_label, result)
    
    colnames(datos_finales) <- c("Partido", "Fecha", "Estado", "Resultado")
    
    datatable(
      datos_finales,
      options = list(
        pageLength = 10,
        dom = 'tip',
        language = list(
          search = "🔍 Buscar:",
          lengthMenu = "Mostrar _MENU_ registros",
          info = "Mostrando _START_ a _END_ de _TOTAL_ registros",
          paginate = list(
            previous = "⬅️ Anterior",
            `next` = "Siguiente ➡️"
          ),
          emptyTable = "No hay partidos para mostrar"
        )
      ),
      rownames = FALSE,
      selection = "none",
      escape = FALSE
    ) %>%
      formatStyle(
        'Estado',
        backgroundColor = styleEqual(
          c("✅ Finalizado", "⏳ Programado"),
          c('#e8f5e9', '#e3f2fd')
        )
      )
  })
  
  # Historial de jugador (nueva implementación segura)
  output$titulo_historial_jugador <- renderText({
    req(input$jugador_historial)
    paste("🎾 Historial de", input$jugador_historial)
  })
  
  # Función segura para obtener historial de jugador
  obtener_historial_jugador <- function(jugador) {
    if (nrow(resultados()) == 0 || is.null(jugador) || jugador == "") {
      return(data.frame(
        Fecha = character(),
        Rival = character(),
        `Mi Resultado` = character(),
        Resultado = character(),
        stringsAsFactors = FALSE
      ))
    }
    
    # Filtrar partidos del jugador
    partidos_jugador <- resultados() %>%
      filter(jugador1 == jugador | jugador2 == jugador) %>%
      arrange(desc(fecha))
    
    if (nrow(partidos_jugador) == 0) {
      return(data.frame(
        Fecha = character(),
        Rival = character(),
        `Mi Resultado` = character(),
        Resultado = character(),
        stringsAsFactors = FALSE
      ))
    }
    
    # Crear dataframe de resultados
    historial <- data.frame(
      Fecha = format(partidos_jugador$fecha, "%d/%m/%Y"),
      Rival = ifelse(partidos_jugador$jugador1 == jugador, 
                    partidos_jugador$jugador2, 
                    partidos_jugador$jugador1),
      `Mi Resultado` = character(nrow(partidos_jugador)),
      Resultado = character(nrow(partidos_jugador)),
      stringsAsFactors = FALSE
    )
    
    # Procesar cada partido de manera segura
    for (i in 1:nrow(partidos_jugador)) {
      fila <- partidos_jugador[i, ]
      
      # Construir el resultado
      resultado_str <- paste0(
        ifelse(fila$set1 != "", fila$set1, ""),
        ifelse(fila$set2 != "", paste0(" ", fila$set2), ""),
        ifelse(fila$set3 != "", paste0(" ", fila$set3), "")
      )
      
      # Invertir el resultado si el jugador es el segundo
      if (fila$jugador2 == jugador) {
        resultado_invertido <- sapply(strsplit(c(fila$set1, fila$set2, fila$set3), "-"), function(x) {
          if (length(x) == 2) paste(x[2], x[1], sep = "-") else ""
        })
        resultado_str <- paste(resultado_invertido[resultado_invertido != ""], collapse = " ")
      }
      
      historial$`Mi Resultado`[i] <- resultado_str
      
      # Determinar victoria/derrota de manera segura
      tryCatch({
        # Extraer los resultados de los sets de manera segura
        set1 <- if (is.null(fila$set1) || fila$set1 == "") c(NA, NA) else {
          partes <- str_split(fila$set1, "-", simplify = TRUE)
          if (length(partes) != 2) c(NA, NA) else as.numeric(partes)
        }
        
        set2 <- if (is.null(fila$set2) || fila$set2 == "") c(NA, NA) else {
          partes <- str_split(fila$set2, "-", simplify = TRUE)
          if (length(partes) != 2) c(NA, NA) else as.numeric(partes)
        }
        
        set3 <- if (is.null(fila$set3) || fila$set3 == "") c(NA, NA) else {
          partes <- str_split(fila$set3, "-", simplify = TRUE)
          if (length(partes) != 2) c(NA, NA) else as.numeric(partes)
        }
        
        sets <- list(set1, set2, set3)
        
        sets_j1 <- sum(sapply(sets, function(x) if (!any(is.na(x))) x[1] > x[2] else FALSE))
        sets_j2 <- sum(sapply(sets, function(x) if (!any(is.na(x))) x[2] > x[1] else FALSE))
        
        if (fila$jugador1 == jugador) {
          historial$Resultado[i] <- if (sets_j1 > sets_j2) "🏆 Victoria" else if (sets_j2 > sets_j1) "❌ Derrota" else "🤝 Empate"
        } else {
          historial$Resultado[i] <- if (sets_j2 > sets_j1) "🏆 Victoria" else if (sets_j1 > sets_j2) "❌ Derrota" else "🤝 Empate"
        }
      }, error = function(e) {
        historial$Resultado[i] <- "❓ Error"
      })
    }
    
    return(historial)
  }
  
  # Función para calcular estadísticas de un jugador específico
  calcular_estadisticas_jugador <- function(jugador) {
    if (nrow(resultados()) == 0 || is.null(jugador) || jugador == "") {
      return(list(
        partidos_jugados = 0,
        partidos_ganados = 0,
        sets_ganados = 0,
        efectividad = 0
      ))
    }
    
    partidos_jugador <- resultados() %>%
      filter(jugador1 == jugador | jugador2 == jugador)
    
    if (nrow(partidos_jugador) == 0) {
      return(list(
        partidos_jugados = 0,
        partidos_ganados = 0,
        sets_ganados = 0,
        efectividad = 0
      ))
    }
    
    partidos_ganados <- 0
    sets_ganados <- 0
    
    for (i in 1:nrow(partidos_jugador)) {
      fila <- partidos_jugador[i, ]
      
      tryCatch({
        # Extraer los resultados de los sets de manera segura
        set1 <- if (is.null(fila$set1) || fila$set1 == "") c(NA, NA) else {
          partes <- str_split(fila$set1, "-", simplify = TRUE)
          if (length(partes) != 2) c(NA, NA) else as.numeric(partes)
        }
        
        set2 <- if (is.null(fila$set2) || fila$set2 == "") c(NA, NA) else {
          partes <- str_split(fila$set2, "-", simplify = TRUE)
          if (length(partes) != 2) c(NA, NA) else as.numeric(partes)
        }
        
        set3 <- if (is.null(fila$set3) || fila$set3 == "") c(NA, NA) else {
          partes <- str_split(fila$set3, "-", simplify = TRUE)
          if (length(partes) != 2) c(NA, NA) else as.numeric(partes)
        }
        
        sets <- list(set1, set2, set3)
        
        sets_j1 <- sum(sapply(sets, function(x) if (!any(is.na(x))) x[1] > x[2] else FALSE))
        sets_j2 <- sum(sapply(sets, function(x) if (!any(is.na(x))) x[2] > x[1] else FALSE))
        
        # Contar sets ganados por el jugador
        if (fila$jugador1 == jugador) {
          sets_ganados <- sets_ganados + sets_j1
          if (sets_j1 > sets_j2) partidos_ganados <- partidos_ganados + 1
        } else {
          sets_ganados <- sets_ganados + sets_j2
          if (sets_j2 > sets_j1) partidos_ganados <- partidos_ganados + 1
        }
      }, error = function(e) {
        # En caso de error, no hacer nada
      })
    }
    
    efectividad <- if (nrow(partidos_jugador) > 0) {
      round(partidos_ganados / nrow(partidos_jugador) * 100, 1)
    } else {
      0
    }
    
    return(list(
      partidos_jugados = nrow(partidos_jugador),
      partidos_ganados = partidos_ganados,
      sets_ganados = sets_ganados,
      efectividad = efectividad
    ))
  }
  
  # Tabla de historial de jugador
  output$tabla_historial_jugador <- renderDT({
    req(input$ver_historial > 0, input$jugador_historial)
    
    historial <- obtener_historial_jugador(input$jugador_historial)
    
    if (nrow(historial) == 0) {
      return(datatable(data.frame(Mensaje = "Este jugador no tiene partidos registrados"), 
                      options = list(dom = "t")))
    }
    
    datatable(historial, 
              options = list(
                dom = "tp", 
                pageLength = 10,
                scrollX = TRUE,
                language = list(
                  search = "🔍 Buscar:",
                  info = "Mostrando _START_ a _END_ de _TOTAL_ partidos"
                )
              ),
              rownames = FALSE,
              escape = FALSE) %>%
      formatStyle("Resultado",
                  backgroundColor = styleEqual(c("🏆 Victoria", "❌ Derrota", "🤝 Empate"), 
                                             c("#c8e6c9", "#ffcdd2", "#fff3e0")))
  })
  
  # Value boxes para historial de jugador
  output$partidos_jugados_jugador <- renderValueBox({
    req(input$ver_historial > 0, input$jugador_historial)
    stats <- calcular_estadisticas_jugador(input$jugador_historial)
    valueBox(
      stats$partidos_jugados,
      "Partidos Jugados",
      icon = icon("chart-bar"),
      color = "green"
    )
  })
  
  output$partidos_ganados_jugador <- renderValueBox({
    req(input$ver_historial > 0, input$jugador_historial)
    stats <- calcular_estadisticas_jugador(input$jugador_historial)
    valueBox(
      stats$partidos_ganados,
      "Partidos Ganados",
      icon = icon("trophy"),
      color = "yellow"
    )
  })
  
  output$sets_ganados_jugador <- renderValueBox({
    req(input$ver_historial > 0, input$jugador_historial)
    stats <- calcular_estadisticas_jugador(input$jugador_historial)
    valueBox(
      stats$sets_ganados,
      "Sets Ganados",
      icon = icon("chart-line"),
      color = "aqua"
    )
  })
  
  output$efectividad_jugador <- renderValueBox({
    req(input$ver_historial > 0, input$jugador_historial)
    stats <- calcular_estadisticas_jugador(input$jugador_historial)
    valueBox(
      paste0(stats$efectividad, "%"),
      "Efectividad",
      icon = icon("percent"),
      color = "blue"
    )
  })
  
  # Próximos partidos mini
  output$proximos_mini <- renderTable({
    upcoming <- proximos_partidos() %>%
      head(5) %>%
      mutate(
        match_date = format(as.Date(fecha), "%d/%m/%Y"),
        match = paste("🎾", jugador1, "vs", jugador2)
      ) %>%
      select(match, match_date)
    
    if (nrow(upcoming) == 0) {
      data.frame(
        "Partido" = "No hay partidos programados",
        "Fecha" = "-"
      )
    } else {
      colnames(upcoming) <- c("Partido", "Fecha")
      upcoming
    }
  }, striped = TRUE, hover = TRUE)
  
  output$tabla_proximos <- renderDT({
    if (nrow(proximos_partidos()) == 0) {
      return(datatable(data.frame(Mensaje = "No hay partidos programados"), 
                      options = list(dom = "t")))
    }
    
    datos <- proximos_partidos() %>%
      arrange(fecha, hora) %>%
      mutate(Fecha = format(fecha, "%d/%m/%Y")) %>%
      select(Fecha, Hora = hora, `Jugador 1` = jugador1, `Jugador 2` = jugador2)
    
    datatable(datos, 
              options = list(
                dom = "tp", 
                pageLength = 10,
                scrollX = TRUE,
                language = list(
                  search = "🔍 Buscar:",
                  info = "Mostrando _START_ a _END_ de _TOTAL_ partidos"
                )
              ),
              rownames = FALSE)
  })
  
  # Value boxes actualizadas
  output$total_partidos_jugados <- renderValueBox({
    stats <- calcular_estadisticas()
    valueBox(
      stats$partidos_jugados,
      "Partidos Jugados",
      icon = icon("chart-bar"),
      color = "green"
    )
  })
  
  output$total_sets_disputados <- renderValueBox({
    stats <- calcular_estadisticas()
    valueBox(
      stats$sets_disputados,
      "Sets Disputados",
      icon = icon("chart-line"),
      color = "aqua"
    )
  })
  
  output$total_games_disputados <- renderValueBox({
    stats <- calcular_estadisticas()
    valueBox(
      stats$games_disputados,
      "Games Disputados",
      icon = icon("chart-area"),
      color = "blue"
    )
  })
  
  output$lider_torneo <- renderValueBox({
    stats <- calcular_estadisticas()
    if (nrow(stats$resumen_jugadores) == 0) {
      lider <- "Sin datos"
    } else {
      lider <- stats$resumen_jugadores$Jugador[1]
    }
    
    valueBox(
      lider,
      "Líder Actual",
      icon = icon("crown"),
      color = "yellow"
    )
  })
  
  # Lista de jugadores para admin con opciones de edición
  output$lista_jugadores <- renderDT({
    if (nrow(jugadores()) == 0) return(NULL)
    
    datos <- jugadores() %>%
      mutate(
        Acciones = paste0(
          '<button class="btn btn-warning btn-xs" onclick="Shiny.setInputValue(\'editar_jugador\', \'', nombre, '\')">✏️</button> ',
          '<button class="btn btn-danger btn-xs" onclick="Shiny.setInputValue(\'eliminar_jugador\', \'', nombre, '\')">🗑️</button>'
        )
      )
    
    datatable(datos, 
              options = list(dom = "tp", pageLength = 5),
              rownames = FALSE,
              escape = FALSE)
  })
  
  # Gestión de resultados para admin
  output$gestion_resultados <- renderDT({
    if (nrow(resultados()) == 0) return(NULL)
    
    datos <- resultados() %>%
      arrange(desc(fecha)) %>%
      mutate(
        Partido = paste(jugador1, "vs", jugador2),
        Resultado = paste(set1, set2, ifelse(set3 != "", set3, "")),
        Fecha = format(fecha, "%d/%m/%Y"),
        Acciones = paste0(
          '<button class="btn btn-warning btn-xs" onclick="Shiny.setInputValue(\'editar_resultado\', ', row_number(), ')">✏️</button> ',
          '<button class="btn btn-danger btn-xs" onclick="Shiny.setInputValue(\'eliminar_resultado\', ', row_number(), ')">🗑️</button>'
        )
      ) %>%
      select(Fecha, Partido, Resultado, Acciones)
    
    datatable(datos, 
              options = list(dom = "tp", pageLength = 10),
              rownames = FALSE,
              escape = FALSE)
  })
  
  output$partidos_programados_admin <- renderDT({
    if (nrow(proximos_partidos()) == 0) return(NULL)
    
    datos <- proximos_partidos() %>%
      arrange(fecha, hora) %>%
      mutate(
        Fecha = format(fecha, "%d/%m/%Y"),
        Acciones = paste0(
          '<button class="btn btn-danger btn-xs" onclick="Shiny.setInputValue(\'eliminar_partido\', ', row_number(), ')">🗑️</button>'
        )
      ) %>%
      select(Fecha, Hora = hora, `Jugador 1` = jugador1, `Jugador 2` = jugador2, Acciones)
    
    datatable(datos, 
              options = list(dom = "tp", pageLength = 10),
              rownames = FALSE,
              escape = FALSE)
  })
  
  # Manejar edición y eliminación de jugadores
  observeEvent(input$editar_jugador, {
    showModal(modalDialog(
      title = "✏️ Editar Jugador",
      textInput("nuevo_nombre_jugador", "Nuevo nombre:", value = input$editar_jugador),
      footer = tagList(
        modalButton("Cancelar"),
        actionButton("confirmar_editar_jugador", "💾 Guardar", class = "btn-success")
      )
    ))
  })
  
  observeEvent(input$confirmar_editar_jugador, {
    req(input$nuevo_nombre_jugador != "")
    
    nombre_anterior <- input$editar_jugador
    nombre_nuevo <- trimws(input$nuevo_nombre_jugador)
    
    # Actualizar en jugadores
    jugadores_actualizados <- jugadores()
    jugadores_actualizados$nombre[jugadores_actualizados$nombre == nombre_anterior] <- nombre_nuevo
    jugadores(jugadores_actualizados)
    saveRDS(jugadores_actualizados, jugadores_path)
    
    # Actualizar en resultados
    resultados_actualizados <- resultados()
    resultados_actualizados$jugador1[resultados_actualizados$jugador1 == nombre_anterior] <- nombre_nuevo
    resultados_actualizados$jugador2[resultados_actualizados$jugador2 == nombre_anterior] <- nombre_nuevo
    resultados(resultados_actualizados)
    saveRDS(resultados_actualizados, resultados_path)
    
    # Actualizar en próximos partidos
    proximos_actualizados <- proximos_partidos()
    proximos_actualizados$jugador1[proximos_actualizados$jugador1 == nombre_anterior] <- nombre_nuevo
    proximos_actualizados$jugador2[proximos_actualizados$jugador2 == nombre_anterior] <- nombre_nuevo
    proximos_partidos(proximos_actualizados)
    saveRDS(proximos_actualizados, proximos_path)
    
    removeModal()
    showNotification("✅ Jugador actualizado exitosamente", type = "message")
  })
  
  observeEvent(input$eliminar_jugador, {
    showModal(modalDialog(
      title = "🗑️ Eliminar Jugador",
      paste("¿Estás seguro de que quieres eliminar a", input$eliminar_jugador, "?"),
      p("Esta acción también eliminará todos sus resultados y partidos programados."),
      footer = tagList(
        modalButton("Cancelar"),
        actionButton("confirmar_eliminar_jugador", "🗑️ Eliminar", class = "btn-danger")
      )
    ))
  })
  
  observeEvent(input$confirmar_eliminar_jugador, {
    nombre_eliminar <- input$eliminar_jugador
    
    # Eliminar de jugadores
    jugadores_actualizados <- jugadores() %>%
      filter(nombre != nombre_eliminar)
    jugadores(jugadores_actualizados)
    saveRDS(jugadores_actualizados, jugadores_path)
    
    # Eliminar de resultados
    resultados_actualizados <- resultados() %>%
      filter(jugador1 != nombre_eliminar & jugador2 != nombre_eliminar)
    resultados(resultados_actualizados)
    saveRDS(resultados_actualizados, resultados_path)
    
    # Eliminar de próximos partidos
    proximos_actualizados <- proximos_partidos() %>%
      filter(jugador1 != nombre_eliminar & jugador2 != nombre_eliminar)
    proximos_partidos(proximos_actualizados)
    saveRDS(proximos_actualizados, proximos_path)
    
    removeModal()
    showNotification("✅ Jugador eliminado exitosamente", type = "message")
  })
  
  # Manejar eliminación de resultados
  observeEvent(input$eliminar_resultado, {
    showModal(modalDialog(
      title = "🗑️ Eliminar Resultado",
      "¿Estás seguro de que quieres eliminar este resultado?",
      footer = tagList(
        modalButton("Cancelar"),
        actionButton("confirmar_eliminar_resultado", "🗑️ Eliminar", class = "btn-danger")
      )
    ))
  })
  
  observeEvent(input$confirmar_eliminar_resultado, {
    indice <- as.numeric(input$eliminar_resultado)
    resultados_actualizados <- resultados()[-indice, ]
    resultados(resultados_actualizados)
    saveRDS(resultados_actualizados, resultados_path)
    
    removeModal()
    showNotification("✅ Resultado eliminado exitosamente", type = "message")
  })
  
  # Manejar eliminación de partidos programados
  observeEvent(input$eliminar_partido, {
    showModal(modalDialog(
      title = "🗑️ Eliminar Partido",
      "¿Estás seguro de que quieres eliminar este partido programado?",
      footer = tagList(
        modalButton("Cancelar"),
        actionButton("confirmar_eliminar_partido", "🗑️ Eliminar", class = "btn-danger")
      )
    ))
  })
  
  observeEvent(input$confirmar_eliminar_partido, {
    indice <- as.numeric(input$eliminar_partido)
    proximos_actualizados <- proximos_partidos()[-indice, ]
    proximos_partidos(proximos_actualizados)
    saveRDS(proximos_actualizados, proximos_path)
    
    removeModal()
    showNotification("✅ Partido eliminado exitosamente", type = "message")
  })
}

shinyApp(ui, server)
