package com.example.resolucionurbana

import android.graphics.Color
import android.location.Location
import android.os.Bundle
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.example.resolucionurbana.databinding.ActivityMapsBinding
import com.google.android.gms.maps.CameraUpdateFactory
import com.google.android.gms.maps.GoogleMap
import com.google.android.gms.maps.OnMapReadyCallback
import com.google.android.gms.maps.SupportMapFragment
import com.google.android.gms.maps.model.*

class MapsActivity : AppCompatActivity(), OnMapReadyCallback {

    private lateinit var mMap: GoogleMap
    private lateinit var binding: ActivityMapsBinding

    private var idIncidencia: String? = null
    private var tipoIncidencia: String? = null
    private var inspector: String? = null
    private var brigada: String? = null
    private var latIncidencia: Double = 0.0
    private var lngIncidencia: Double = 0.0

    // Ubicación ficticia del técnico para el ejercicio
    private val latTecnico = -0.180653
    private val lngTecnico = -78.467834

    private var markerIncidencia: Marker? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        binding = ActivityMapsBinding.inflate(layoutInflater)
        setContentView(binding.root)

        // Extraer datos del Intent
        idIncidencia = intent.getStringExtra(ContratoIncidencias.EXTRA_ID) ?: "000"
        tipoIncidencia = intent.getStringExtra(ContratoIncidencias.EXTRA_TIPO) ?: "Incidencia Genérica"
        inspector = intent.getStringExtra(ContratoIncidencias.EXTRA_INSPECTOR) ?: "No asignado"
        brigada = intent.getStringExtra(ContratoIncidencias.EXTRA_BRIGADA) ?: "Sin brigada"
        latIncidencia = intent.getDoubleExtra(ContratoIncidencias.EXTRA_LATITUD, -0.175)
        lngIncidencia = intent.getDoubleExtra(ContratoIncidencias.EXTRA_LONGITUD, -78.483)

        // Mostrar datos en el UI
        binding.tvTituloIncidencia.text = "$tipoIncidencia ($idIncidencia)"
        binding.tvDetalles.text = "Inspector: $inspector\nBrigada: $brigada"

        // Configurar fragmento del mapa
        val mapFragment = supportFragmentManager
            .findFragmentById(R.id.map) as SupportMapFragment
        mapFragment.getMapAsync(this)

        // Configurar botón
        binding.btnResolver.setOnClickListener {
            ejecutarResolucion()
        }
    }

    override fun onMapReady(googleMap: GoogleMap) {
        mMap = googleMap

        val posIncidencia = LatLng(latIncidencia, lngIncidencia)
        val posTecnico = LatLng(latTecnico, lngTecnico)

        // Marcador Incidencia (Naranja)
        markerIncidencia = mMap.addMarker(
            MarkerOptions()
                .position(posIncidencia)
                .title("Incidencia: $tipoIncidencia")
                .snippet("Estado: EN_ATENCION")
                .icon(BitmapDescriptorFactory.defaultMarker(BitmapDescriptorFactory.HUE_ORANGE))
        )

        // Marcador Técnico (Azul)
        mMap.addMarker(
            MarkerOptions()
                .position(posTecnico)
                .title("Mi Ubicación (Técnico)")
                .icon(BitmapDescriptorFactory.defaultMarker(BitmapDescriptorFactory.HUE_AZURE))
        )

        // Trazar Polyline azul
        mMap.addPolyline(
            PolylineOptions()
                .add(posTecnico, posIncidencia)
                .width(5f)
                .color(Color.BLUE)
        )

        // Ajustar cámara para mostrar ambos
        val bounds = LatLngBounds.Builder()
            .include(posIncidencia)
            .include(posTecnico)
            .build()

        mMap.animateCamera(CameraUpdateFactory.newLatLngBounds(bounds, 150))
    }

    private fun ejecutarResolucion() {
        val tecnico = binding.etTecnico.text.toString()
        val solucion = binding.etSolucion.text.toString()
        val materiales = binding.etMateriales.text.toString()

        // Validar campos
        if (tecnico.isEmpty() || solucion.isEmpty() || materiales.isEmpty()) {
            Toast.makeText(this, "Por favor complete todos los campos", Toast.LENGTH_SHORT).show()
            return
        }

        // Calcular distancia
        val locIncidencia = Location("").apply {
            latitude = latIncidencia
            longitude = lngIncidencia
        }
        val locTecnico = Location("").apply {
            latitude = latTecnico
            longitude = lngTecnico
        }

        val distancia = locTecnico.distanceTo(locIncidencia)

        if (distancia > 150) {
            Toast.makeText(
                this,
                "Advertencia: Está a ${distancia.toInt()}m. Debe estar a menos de 150m para resolver.",
                Toast.LENGTH_LONG
            ).show()
        } else {
            // Éxito
            markerIncidencia?.setIcon(BitmapDescriptorFactory.defaultMarker(BitmapDescriptorFactory.HUE_GREEN))
            markerIncidencia?.snippet = "Estado: RESUELTO"
            
            Toast.makeText(this, "¡Incidencia Resuelta con Éxito!", Toast.LENGTH_SHORT).show()
            
            // Aquí se enviaría el resultado a la App 1/2 o se guardaría en DB
            binding.btnResolver.isEnabled = false
            binding.btnResolver.text = "RESUELTO"
        }
    }
}
