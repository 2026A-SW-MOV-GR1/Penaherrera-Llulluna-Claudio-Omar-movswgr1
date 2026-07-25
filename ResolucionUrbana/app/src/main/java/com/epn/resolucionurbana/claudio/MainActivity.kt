package com.epn.resolucionurbana.claudio

import android.Manifest
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.location.Location
import android.os.Bundle
import android.widget.Toast
import androidx.activity.ComponentActivity
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.Info
import androidx.compose.material.icons.filled.Share
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.core.content.ContextCompat
import com.epn.resolucionurbana.claudio.ui.theme.ResolucionUrbanaTheme
import com.google.android.gms.location.LocationServices
import com.google.android.gms.maps.CameraUpdateFactory
import com.google.android.gms.maps.model.BitmapDescriptorFactory
import com.google.android.gms.maps.model.CameraPosition
import com.google.android.gms.maps.model.LatLng
import com.google.maps.android.compose.*
import java.text.SimpleDateFormat
import java.util.*
import kotlin.math.*

class MainActivity : ComponentActivity() {
    private var incidenteEstado = mutableStateOf(Incidente(idIncidente = "S/N", tipoIncidente = "Esperando datos..."))

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()

        incidenteEstado.value = recibirDatosDeSaul(intent)

        setContent {
            ResolucionUrbanaTheme {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = Color.White
                ) {
                    MainContent(incidenteEstado.value)
                }
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        incidenteEstado.value = recibirDatosDeSaul(intent)
    }

    private fun recibirDatosDeSaul(intent: Intent?): Incidente {
        android.util.Log.d("RESOLUCION_DEBUG", "Intent recibido: ${intent?.action}")
        if (intent == null) return crearIncidenteVacio()

        val extras = intent.extras
        if (extras != null) {
            val keys = extras.keySet().joinToString(", ")
            android.util.Log.d("RESOLUCION_DEBUG", "Llaves detectadas: $keys")
            
            // Receptor robusto con múltiples fallos (snake_case y camelCase) para integración universal
            val id = intent.getStringExtra("idIncidente") ?: intent.getStringExtra("id_incidente")
            if (id != null) {
                // Coordenadas de Quito por defecto si vienen en 0.0
                val lat = if (intent.hasExtra("latitud")) intent.getDoubleExtra("latitud", 0.0) else intent.getDoubleExtra("latitud_incidente", 0.0)
                val lon = if (intent.hasExtra("longitud")) intent.getDoubleExtra("longitud", 0.0) else intent.getDoubleExtra("longitud_incidente", 0.0)
                
                return Incidente(
                    idIncidente = id,
                    tipoIncidente = intent.getStringExtra("tipoIncidente") ?: intent.getStringExtra("tipo_incidente") ?: "",
                    descripcion = intent.getStringExtra("descripcion") ?: intent.getStringExtra("desc") ?: intent.getStringExtra("descripcion_incidente") ?: "",
                    latitud = if (lat != 0.0) lat else -0.1807,
                    longitud = if (lon != 0.0) lon else -78.4678,
                    prioridad = intent.getStringExtra("prioridad") ?: intent.getStringExtra("prioridad_incidente") ?: "",
                    fechaReporte = intent.getStringExtra("fechaReporte") ?: intent.getStringExtra("fecha_reporte") ?: "",
                    estado = intent.getStringExtra("estado") ?: intent.getStringExtra("estado_incidente") ?: "REPORTADO",
                    nombreInspector = intent.getStringExtra("nombreInspector") ?: intent.getStringExtra("nombre_inspector") ?: "",
                    brigadaAsignada = intent.getStringExtra("brigadaAsignada") ?: intent.getStringExtra("brigada_asignada") ?: "",
                    latitudBrigada = if (intent.hasExtra("latitudBrigada")) intent.getDoubleExtra("latitudBrigada", 0.0) else intent.getDoubleExtra("lat_brigada", 0.0),
                    longitudBrigada = if (intent.hasExtra("longitudBrigada")) intent.getDoubleExtra("longitudBrigada", 0.0) else intent.getDoubleExtra("lon_brigada", 0.0),
                    resultadoInspeccion = intent.getStringExtra("resultadoInspeccion") ?: intent.getStringExtra("resultado_inspeccion") ?: "",
                    fechaInspeccion = intent.getStringExtra("fechaInspeccion") ?: intent.getStringExtra("fecha_inspeccion") ?: "",
                    prioridadConfirmada = intent.getStringExtra("prioridadConfirmada") ?: intent.getStringExtra("prioridad_confirmada") ?: ""
                )
            }
        }
        
        // Si no hay extras individuales, intentar el objeto completo
        val parcelableIncidente = if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.TIRAMISU) {
            intent.getParcelableExtra("incidente", Incidente::class.java)
        } else {
            @Suppress("DEPRECATION")
            intent.getParcelableExtra("incidente")
        }

        return parcelableIncidente ?: crearIncidenteVacio()
    }

    private fun crearIncidenteVacio(): Incidente {
        return Incidente(
            idIncidente = "ID-PENDIENTE",
            tipoIncidente = "Sin datos de App 2",
            descripcion = "En espera de recepción de incidente...",
            estado = "ESPERANDO",
            nombreInspector = "Por asignar",
            brigadaAsignada = "Por asignar",
            latitud = -0.1807, // Quito
            longitud = -78.4678
        )
    }
}

@Composable
fun MainContent(incidenteInicial: Incidente) {
    var incidente by remember(incidenteInicial) { mutableStateOf(incidenteInicial) }
    var mostrarResumenFinal by remember(incidenteInicial) { mutableStateOf(false) }

    if (mostrarResumenFinal) {
        ResumenFinalScreen(incidente) {
            mostrarResumenFinal = false
        }
    } else {
        ResolucionScreen(incidente) { finalIncidente ->
            incidente = finalIncidente
            mostrarResumenFinal = true
        }
    }
}

@Composable
fun ResolucionScreen(incidente: Incidente, onFinalizar: (Incidente) -> Unit) {
    val context = LocalContext.current
    val scrollState = rememberScrollState()
    var trabajoRealizado by remember { mutableStateOf("") }
    var materialesUtilizados by remember { mutableStateOf("") }
    var responsableResolucion by remember { mutableStateOf("") }
    var observacionesFinales by remember { mutableStateOf("") }
    
    val cardGradient = Brush.linearGradient(colors = listOf(Color(0xFF43A047), Color(0xFF1E88E5)))
    val incidentLatLng = if (incidente.latitud != 0.0) LatLng(incidente.latitud, incidente.longitud) else LatLng(-0.1807, -78.4678)

    var userLocation by remember { mutableStateOf<LatLng?>(null) }
    // SIMULACIÓN: Inicia en un punto ALEATORIO de Quito (evita distancia fija)
    var simulatedLocation by remember(incidente.idIncidente) { 
        val r = Random()
        val randomLat = -0.1807 + (r.nextDouble() - 0.5) * 0.08
        val randomLon = -78.4678 + (r.nextDouble() - 0.5) * 0.08
        mutableStateOf<LatLng?>(LatLng(randomLat, randomLon))
    }
    val effectiveLocation = simulatedLocation ?: userLocation
    
    val fusedLocationClient = remember { LocationServices.getFusedLocationProviderClient(context) }
    var tienePermisoMapa by remember { 
        mutableStateOf(ContextCompat.checkSelfPermission(context, Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED) 
    }
    
    val launcher = rememberLauncherForActivityResult(ActivityResultContracts.RequestMultiplePermissions()) { permissions ->
        tienePermisoMapa = permissions[Manifest.permission.ACCESS_FINE_LOCATION] == true
    }

    LaunchedEffect(tienePermisoMapa) {
        if (tienePermisoMapa) {
            val locationRequest = com.google.android.gms.location.LocationRequest.Builder(com.google.android.gms.location.Priority.PRIORITY_HIGH_ACCURACY, 5000).build()
            val locationCallback = object : com.google.android.gms.location.LocationCallback() {
                override fun onLocationResult(p0: com.google.android.gms.location.LocationResult) {
                    p0.lastLocation?.let { if (simulatedLocation == null) userLocation = LatLng(it.latitude, it.longitude) }
                }
            }
            fusedLocationClient.requestLocationUpdates(locationRequest, locationCallback, android.os.Looper.getMainLooper())
        } else {
            launcher.launch(arrayOf(Manifest.permission.ACCESS_FINE_LOCATION, Manifest.permission.ACCESS_COARSE_LOCATION))
        }
    }

    val cyanColor = Color(0xFF009688)

    val distancia = effectiveLocation?.let { calcularDistancia(it, incidentLatLng) } ?: Double.MAX_VALUE
    val estaCerca = distancia < 500

    Column(
        modifier = Modifier.fillMaxSize().background(Color.White).padding(16.dp).verticalScroll(scrollState),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Spacer(modifier = Modifier.height(48.dp))
        
        Card(modifier = Modifier.fillMaxWidth(), shape = RoundedCornerShape(16.dp), elevation = CardDefaults.cardElevation(defaultElevation = 6.dp)) {
            Box(modifier = Modifier.fillMaxWidth().background(cardGradient).padding(16.dp)) {
                Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween, verticalAlignment = Alignment.CenterVertically) {
                    Column {
                        Text("PASO 3 DE 3", color = Color.White.copy(alpha = 0.8f), fontSize = 12.sp, fontWeight = FontWeight.Bold)
                        Text("RESOLUCIÓN URBANA", color = Color.White, fontSize = 20.sp, fontWeight = FontWeight.ExtraBold)
                    }
                    Surface(color = Color.White.copy(alpha = 0.2f), shape = RoundedCornerShape(8.dp)) {
                        Text("FASE FINAL", color = Color.White, modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp), fontSize = 12.sp, fontWeight = FontWeight.Bold)
                    }
                }
            }
        }

        Spacer(modifier = Modifier.height(16.dp))

        InfoSection(title = "1. Origen del Reporte ", cyanColor) {
            InfoRow("ID:", incidente.idIncidente)
            InfoRow("Tipo:", incidente.tipoIncidente)
            InfoRow("Desc.:", incidente.descripcion)
            InfoRow("Prioridad:", incidente.prioridad)
            InfoRow("Ubicación:", "${incidente.latitud}, ${incidente.longitud}")
        }

        InfoSection(title = "2. Inspección y Brigada ", cyanColor) {
            InfoRow("Inspector:", incidente.nombreInspector)
            InfoRow("Brigada:", incidente.brigadaAsignada)
            InfoRow("Ubic. Brigada:", "${incidente.latitudBrigada}, ${incidente.longitudBrigada}")
            InfoRow("Prioridad C.:", incidente.prioridadConfirmada)
            InfoRow("Resultado:", incidente.resultadoInspeccion)
            InfoRow("Fecha Insp.:", incidente.fechaInspeccion)
        }

        Text("3. Ubicación y Geofencing (Rango 500m)", color = Color.Black, fontWeight = FontWeight.Bold, modifier = Modifier.align(Alignment.Start).padding(top = 12.dp))
        Card(modifier = Modifier.height(280.dp).fillMaxWidth().padding(vertical = 8.dp), shape = RoundedCornerShape(12.dp), elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)) {
            val cameraPositionState = rememberCameraPositionState { position = CameraPosition.fromLatLngZoom(incidentLatLng, 15f) }

            LaunchedEffect(incidentLatLng, effectiveLocation) {
                if (effectiveLocation != null) {
                    val bounds = com.google.android.gms.maps.model.LatLngBounds.Builder()
                        .include(incidentLatLng)
                        .include(effectiveLocation)
                        .build()
                    cameraPositionState.animate(CameraUpdateFactory.newLatLngBounds(bounds, 120))
                }
            }

            GoogleMap(modifier = Modifier.fillMaxSize(), cameraPositionState = cameraPositionState, properties = MapProperties(isMyLocationEnabled = true)) {
                Marker(state = MarkerState(position = incidentLatLng), title = "Incidente: ${incidente.estado}", icon = BitmapDescriptorFactory.defaultMarker(obtenerColorMarcador(incidente.estado)))
                
                // Círculo de Geofencing (500m) - Requerido dinámico
                Circle(
                    center = incidentLatLng,
                    radius = 500.0,
                    fillColor = if (estaCerca) Color(0x334CAF50) else Color(0x33FF9800), // Verde vs Naranja
                    strokeColor = if (estaCerca) Color(0xFF4CAF50) else Color(0xFFFF9800),
                    strokeWidth = 3f
                )

                if (incidente.latitudBrigada != 0.0) {
                    Marker(state = MarkerState(position = LatLng(incidente.latitudBrigada, incidente.longitudBrigada)), title = "Lugar Inspección", icon = BitmapDescriptorFactory.defaultMarker(BitmapDescriptorFactory.HUE_GREEN))
                }

                effectiveLocation?.let {
                    Marker(state = MarkerState(position = it), title = "Mi Ubicación", icon = BitmapDescriptorFactory.defaultMarker(BitmapDescriptorFactory.HUE_AZURE))
                    Polyline(points = listOf(it, incidentLatLng), color = Color(0xFF1E88E5), width = 8f, pattern = listOf(com.google.android.gms.maps.model.Dash(20f), com.google.android.gms.maps.model.Gap(10f)))
                }
            }
        }

        // ÚNICA SECCIÓN DE CONTROLES DE SIMULACIÓN (Limpiado)
        Row(modifier = Modifier.fillMaxWidth().padding(vertical = 4.dp), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            OutlinedButton(
                onClick = {
                    val r = Random()
                    val lat = -0.1807 + (r.nextDouble() - 0.5) * 0.15
                    val lon = -78.4678 + (r.nextDouble() - 0.5) * 0.15
                    simulatedLocation = LatLng(lat, lon)
                },
                modifier = Modifier.weight(1f)
            ) {
                Text("Ubic. Random", fontSize = 11.sp)
            }
            Button(
                onClick = {
                    val r = Random()
                    // Mueve al usuario dentro del círculo de 500m
                    val offsetLat = (r.nextDouble() - 0.5) * 0.004
                    val offsetLon = (r.nextDouble() - 0.5) * 0.004
                    simulatedLocation = LatLng(incidentLatLng.latitude + offsetLat, incidentLatLng.longitude + offsetLon)
                },
                modifier = Modifier.weight(1f),
                colors = ButtonDefaults.buttonColors(containerColor = Color(0xFF1E88E5))
            ) {
                Text("Llegar al Sitio", fontSize = 11.sp)
            }
        }

        // El cálculo de distancia se movió arriba de Column para ser usado en el Mapa

        Surface(color = if (estaCerca) Color(0xFFE8F5E9) else Color(0xFFFFF3E0), shape = RoundedCornerShape(8.dp), modifier = Modifier.fillMaxWidth().padding(vertical = 8.dp)) {
            Row(modifier = Modifier.padding(12.dp), verticalAlignment = Alignment.CenterVertically) {
                Icon(imageVector = if (estaCerca) Icons.Default.CheckCircle else Icons.Default.Info, contentDescription = null, tint = if (estaCerca) Color(0xFF2E7D32) else Color(0xFFE65100))
                Spacer(modifier = Modifier.width(8.dp))
                Text(text = "Ubicación validada: Estás a ${distancia.toInt()}m. ¡Listo para resolver!", color = if (estaCerca) Color(0xFF2E7D32) else Color(0xFFE65100), fontSize = 14.sp, fontWeight = FontWeight.Bold)
            }
        }

        Divider(modifier = Modifier.padding(vertical = 16.dp))

        Text("DATOS DE RESOLUCIÓN ", color = Color.Black, fontWeight = FontWeight.ExtraBold, fontSize = 18.sp)
        
        OutlinedTextField(value = trabajoRealizado, onValueChange = { trabajoRealizado = it }, label = { Text("Trabajo Realizado") }, modifier = Modifier.fillMaxWidth().padding(vertical = 4.dp))
        OutlinedTextField(value = materialesUtilizados, onValueChange = { materialesUtilizados = it }, label = { Text("Materiales Utilizados") }, modifier = Modifier.fillMaxWidth().padding(vertical = 4.dp))
        OutlinedTextField(value = responsableResolucion, onValueChange = { responsableResolucion = it }, label = { Text("Responsable") }, modifier = Modifier.fillMaxWidth().padding(vertical = 4.dp))
        OutlinedTextField(value = observacionesFinales, onValueChange = { observacionesFinales = it }, label = { Text("Observaciones Finales") }, modifier = Modifier.fillMaxWidth().padding(vertical = 4.dp))

        Button(
            onClick = {
                if (trabajoRealizado.isBlank()) { Toast.makeText(context, "Describa el trabajo", Toast.LENGTH_SHORT).show(); return@Button }
                if (!estaCerca && effectiveLocation != null) { Toast.makeText(context, "Debe estar en el sitio para cerrar", Toast.LENGTH_SHORT).show(); return@Button }
                val currentFecha = SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault()).format(Date())
                onFinalizar(incidente.copy(trabajoRealizado = trabajoRealizado, materialesUtilizados = materialesUtilizados, responsableResolucion = responsableResolucion, fechaResolucion = currentFecha, observacionesFinales = observacionesFinales, estado = "RESUELTO", estadoFinal = "RESUELTO"))
            },
            modifier = Modifier.fillMaxWidth().padding(vertical = 16.dp).height(56.dp),
            colors = ButtonDefaults.buttonColors(containerColor = Color(0xFF43A047)),
            shape = RoundedCornerShape(12.dp)
        ) {
            Text("CONFIRMAR Y FINALIZAR CASO", color = Color.White, fontWeight = FontWeight.Bold, fontSize = 16.sp)
        }
        Spacer(modifier = Modifier.height(40.dp))
    }
}

@Composable
fun ResumenFinalScreen(incidente: Incidente, onVolver: () -> Unit) {
    val context = LocalContext.current
    val cardGradient = Brush.linearGradient(colors = listOf(Color(0xFF43A047), Color(0xFF1E88E5)))
    
    Column(
        modifier = Modifier.fillMaxSize().background(Color.White).padding(24.dp).verticalScroll(rememberScrollState()),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Spacer(modifier = Modifier.height(48.dp))
        Icon(imageVector = Icons.Default.CheckCircle, contentDescription = null, tint = Color(0xFF43A047), modifier = Modifier.size(80.dp))
        Text("¡INCIDENTE RESUELTO!", color = Color.Black, fontSize = 24.sp, fontWeight = FontWeight.ExtraBold, modifier = Modifier.padding(vertical = 8.dp))
        
        Card(
            modifier = Modifier.height(200.dp).fillMaxWidth().padding(vertical = 8.dp),
            shape = RoundedCornerShape(12.dp),
            elevation = CardDefaults.cardElevation(defaultElevation = 4.dp)
        ) {
            val incidentLatLng = LatLng(incidente.latitud, incidente.longitud)
            val cameraPositionState = rememberCameraPositionState { position = CameraPosition.fromLatLngZoom(incidentLatLng, 15f) }
            GoogleMap(modifier = Modifier.fillMaxSize(), cameraPositionState = cameraPositionState) {
                Marker(
                    state = MarkerState(position = incidentLatLng), 
                    title = "Estado: RESUELTO",
                    icon = BitmapDescriptorFactory.defaultMarker(BitmapDescriptorFactory.HUE_GREEN)
                )
            }
        }

        Card(modifier = Modifier.fillMaxWidth().padding(top = 8.dp), shape = RoundedCornerShape(16.dp), elevation = CardDefaults.cardElevation(defaultElevation = 8.dp)) {
            Box(modifier = Modifier.fillMaxWidth().background(cardGradient).padding(20.dp)) {
                Column {
                    Text("RESUMEN DE CIERRE", color = Color.White, fontWeight = FontWeight.Bold, fontSize = 18.sp)
                    Spacer(modifier = Modifier.height(12.dp))
                    InfoRow("ID Caso:", incidente.idIncidente)
                    InfoRow("Tipo:", incidente.tipoIncidente)
                    InfoRow("Fecha Cierre:", incidente.fechaResolucion)
                    InfoRow("Resolvió:", incidente.responsableResolucion)
                    Divider(color = Color.White.copy(alpha = 0.3f), modifier = Modifier.padding(vertical = 12.dp))
                    Text("Trabajo:", color = Color.White.copy(alpha = 0.7f), fontSize = 12.sp)
                    Text(incidente.trabajoRealizado, color = Color.White, fontWeight = FontWeight.Medium)
                }
            }
        }
        
        Button(
            onClick = { compartirResumen(context, incidente) },
            modifier = Modifier.fillMaxWidth().padding(top = 24.dp).height(50.dp),
            colors = ButtonDefaults.buttonColors(containerColor = Color(0xFF1E88E5))
        ) {
            Icon(Icons.Default.Share, contentDescription = null, modifier = Modifier.size(20.dp))
            Spacer(modifier = Modifier.width(10.dp))
            Text("COMPARTIR REPORTE FINAL", color = Color.White, fontWeight = FontWeight.Bold)
        }

        TextButton(onClick = onVolver, modifier = Modifier.fillMaxWidth().padding(top = 8.dp)) {
            Text("VOLVER AL INICIO", color = Color.Gray)
        }
    }
}

fun obtenerColorMarcador(estado: String): Float {
    val normalized = estado.uppercase()
        .replace(" ", "_")
        .replace("Ó", "O")
        .replace("Í", "I")
        .replace("Á", "A")
        .replace("É", "E")
        .replace("Ú", "U")
    
    return when (normalized) {
        "REPORTADO", "PENDIENTE" -> BitmapDescriptorFactory.HUE_RED
        "EN_ATENCION", "ATENDIENDO", "INSPECCIONADO", "EN_PROCESO" -> BitmapDescriptorFactory.HUE_ORANGE
        "RESUELTO", "FINALIZADO" -> BitmapDescriptorFactory.HUE_GREEN
        else -> BitmapDescriptorFactory.HUE_RED
    }
}

fun compartirResumen(context: Context, incidente: Incidente) {
    val resumen = """
        🏗️ REPORTE FINAL DE RESOLUCIÓN URBANA 🏗️
        -------------------------------------------
        🆔 ID INCIDENTE: ${incidente.idIncidente}
        📂 TIPO: ${incidente.tipoIncidente}
        📊 ESTADO PREVIO: ${incidente.estado}
        🚩 ESTADO FINAL: ${incidente.estadoFinal}
        
        --- 📝 DETALLES DEL REPORTE  ---
        📄 Descripción: ${incidente.descripcion}
        📍 Ubicación: ${incidente.latitud}, ${incidente.longitud}
        ⚡ Prioridad Inicial: ${incidente.prioridad}
        📅 Fecha Reporte: ${incidente.fechaReporte}
        
        --- 🔍 DETALLES DE INSPECCIÓN  ---
        👤 Inspector: ${incidente.nombreInspector}
        🚒 Brigada: ${incidente.brigadaAsignada}
        📍 Ubicación Brigada: ${incidente.latitudBrigada}, ${incidente.longitudBrigada}
        📉 Prioridad Confirmada: ${incidente.prioridadConfirmada}
        📝 Resultado: ${incidente.resultadoInspeccion}
        📅 Fecha Inspección: ${incidente.fechaInspeccion}
        
        --- 🛠️ DETALLES DE RESOLUCIÓN  ---
        👷 Responsable: ${incidente.responsableResolucion}
        🛠️ Trabajo Realizado: ${incidente.trabajoRealizado}
        📦 Materiales: ${incidente.materialesUtilizados}
        💬 Observaciones: ${incidente.observacionesFinales}
        📅 Fecha Resolución: ${incidente.fechaResolucion}
        -------------------------------------------
        ✅ Caso cerrado exitosamente.
    """.trimIndent()

    val sendIntent = Intent().apply {
        action = Intent.ACTION_SEND
        putExtra(Intent.EXTRA_TEXT, resumen)
        type = "text/plain"
    }
    context.startActivity(Intent.createChooser(sendIntent, "Enviar resumen por:"))
}

fun calcularDistancia(p1: LatLng, p2: LatLng): Double {
    val r = 6371000.0 
    val dLat = Math.toRadians(p2.latitude - p1.latitude)
    val dLon = Math.toRadians(p2.longitude - p1.longitude)
    val a = sin(dLat / 2).pow(2) + cos(Math.toRadians(p1.latitude)) * cos(Math.toRadians(p2.latitude)) * sin(dLon / 2).pow(2)
    val c = 2 * atan2(sqrt(a), sqrt(1 - a))
    return r * c
}

@Composable
fun InfoSection(title: String, color: Color, content: @Composable ColumnScope.() -> Unit) {
    val cardGradient = Brush.linearGradient(colors = listOf(Color(0xFF43A047), Color(0xFF1E88E5)))
    Column(modifier = Modifier.fillMaxWidth().padding(vertical = 8.dp)) {
        Text(text = title, color = Color.Black, fontWeight = FontWeight.SemiBold, fontSize = 16.sp)
        Card(modifier = Modifier.fillMaxWidth().padding(top = 4.dp), shape = RoundedCornerShape(12.dp), elevation = CardDefaults.cardElevation(defaultElevation = 4.dp)) {
            Box(modifier = Modifier.fillMaxWidth().background(cardGradient).padding(12.dp)) {
                Column { content() }
            }
        }
    }
}

@Composable
fun InfoRow(label: String, value: String) {
    Row(modifier = Modifier.fillMaxWidth().padding(vertical = 2.dp)) {
        Text(text = label, color = Color.White.copy(alpha = 0.7f), modifier = Modifier.width(110.dp), fontSize = 14.sp)
        Text(text = value, color = Color.White, fontSize = 14.sp, fontWeight = FontWeight.Medium)
    }
}
