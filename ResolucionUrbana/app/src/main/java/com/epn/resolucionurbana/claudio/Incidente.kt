package com.epn.resolucionurbana.claudio

import android.os.Parcelable
import kotlinx.parcelize.Parcelize

@Parcelize
data class Incidente(
    // Parámetros de Priscila (Reporte)
    var idIncidente: String = "",
    var tipoIncidente: String = "",
    var descripcion: String = "",
    var latitud: Double = 0.0,
    var longitud: Double = 0.0,
    var prioridad: String = "",
    var fechaReporte: String = "",
    var estado: String = "REPORTADO",

    // Parámetros de Saul (Atención)
    var nombreInspector: String = "",
    var brigadaAsignada: String = "",
    var latitudBrigada: Double = 0.0,
    var longitudBrigada: Double = 0.0,
    var resultadoInspeccion: String = "",
    var fechaInspeccion: String = "",
    var prioridadConfirmada: String = "",

    // Parámetros de Claudio (Resolución)
    var trabajoRealizado: String = "",
    var materialesUtilizados: String = "",
    var responsableResolucion: String = "",
    var fechaResolucion: String = "",
    var observacionesFinales: String = "",
    var estadoFinal: String = "RESUELTO"
) : Parcelable
