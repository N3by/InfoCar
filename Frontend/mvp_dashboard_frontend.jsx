// Estructura base de MVP estilo dashboard en React + TailwindCSS con datos dummy
// Este esqueleto representa el layout y secciones del frontend

import React, { useState } from 'react';

const multasDummy = [
  {
    nombre: 'Exceso de velocidad',
    fecha: '2025-06-01',
    vencimiento: '2025-07-01',
    valor: '$380.000',
    estatus: 'Pendiente'
  },
  {
    nombre: 'Estacionamiento prohibido',
    fecha: '2025-04-10',
    vencimiento: '2025-05-10',
    valor: '$220.000',
    estatus: 'Pagado'
  },
];

const propietariosDummy = [
  { nombre: 'Juan Pérez', desde: '2023' },
  { nombre: 'Andrea Gómez', desde: '2020 - 2022' },
];

// Funciones de validación para Colombia
const validarCedulaColombiana = (cedula) => {
  // Remover espacios y convertir a string
  const cedulaLimpia = cedula.replace(/\s/g, '');
  
  // Verificar que solo contenga números
  if (!/^\d+$/.test(cedulaLimpia)) {
    return { valida: false, mensaje: 'La cédula solo puede contener números' };
  }
  
  // Verificar longitud (entre 6 y 10 dígitos)
  if (cedulaLimpia.length < 6 || cedulaLimpia.length > 10) {
    return { valida: false, mensaje: 'La cédula debe tener entre 6 y 10 dígitos' };
  }
  
  // Verificar que no sea una secuencia de números iguales
  if (/^(\d)\1+$/.test(cedulaLimpia)) {
    return { valida: false, mensaje: 'La cédula no puede ser una secuencia de números iguales' };
  }
  
  return { valida: true, mensaje: '' };
};

const validarPlacaColombiana = (placa) => {
  // Remover espacios y convertir a mayúsculas
  const placaLimpia = placa.replace(/\s/g, '').toUpperCase();
  
  // Patrones de placas colombianas
  const patrones = [
    // Formato antiguo: ABC-123 (3 letras, guión, 3 números)
    /^[A-Z]{3}-\d{3}$/,
    // Formato nuevo: ABC123 (3 letras, 3 números)
    /^[A-Z]{3}\d{3}$/,
    // Formato especial: ABC-1234 (3 letras, guión, 4 números)
    /^[A-Z]{3}-\d{4}$/,
    // Formato especial: ABC1234 (3 letras, 4 números)
    /^[A-Z]{3}\d{4}$/,
    // Formato motos: ABC-12A (3 letras, guión, 2 números, 1 letra)
    /^[A-Z]{3}-\d{2}[A-Z]$/,
    // Formato motos: ABC12A (3 letras, 2 números, 1 letra)
    /^[A-Z]{3}\d{2}[A-Z]$/
  ];
  
  // Verificar que coincida con algún patrón
  const patronValido = patrones.some(patron => patron.test(placaLimpia));
  
  if (!patronValido) {
    return { 
      valida: false, 
      mensaje: 'Formato de placa inválido. Ejemplos válidos: ABC-123, ABC123, ABC-1234, ABC1234, ABC-12A' 
    };
  }
  
  // Verificar que las letras no sean todas iguales
  const letras = placaLimpia.match(/[A-Z]/g);
  if (letras && letras.length >= 3) {
    const letrasUnicas = [...new Set(letras)];
    if (letrasUnicas.length === 1) {
      return { valida: false, mensaje: 'Las letras de la placa no pueden ser todas iguales' };
    }
  }
  
  return { valida: true, mensaje: '' };
};

const documentosData = {
  perfil: {
    nombre: 'Perfil del Propietario Actual',
    tipo: 'propietario',
    datos: {
      cedula: '123456789',
      nombre: 'Juan Pérez',
      celular: '3001234567',
      correo: 'juan@email.com',
      licencias: 'A2, B1',
      direccion: 'Calle 123 #45-67, Bogotá',
      fechaRegistro: '2023-01-15'
    }
  },
  soat: {
    nombre: 'SOAT',
    tipo: 'documento',
    vencimiento: '2025-11-30',
    valor: '$150.000',
    estado: 'Activo',
    detalles: {
      numero: 'SOAT-2024-001',
      aseguradora: 'Seguros Bolívar',
      cobertura: 'Responsabilidad Civil'
    }
  },
  tecnomecanica: {
    nombre: 'Tecnomecánica',
    tipo: 'documento',
    vencimiento: '2025-10-15',
    valor: '$180.000',
    estado: 'Activo',
    detalles: {
      numero: 'TM-2024-002',
      centro: 'Centro de Diagnóstico Automotor',
      resultado: 'Aprobado'
    }
  },
  impuesto: {
    nombre: 'Impuesto Vehicular',
    tipo: 'documento',
    vencimiento: '2025-12-31',
    valor: '$320.000',
    estado: 'Pendiente',
    detalles: {
      año: '2024',
      periodo: 'Enero - Diciembre',
      descuento: '5% por pago anticipado'
    }
  },
  historial: {
    nombre: 'Historial de Propietarios',
    tipo: 'historial',
    datos: [
      { nombre: 'Juan Pérez', desde: '2023', hasta: 'Actual', cedula: '123456789' },
      { nombre: 'Andrea Gómez', desde: '2020', hasta: '2022', cedula: '987654321' },
      { nombre: 'Carlos López', desde: '2018', hasta: '2019', cedula: '456789123' }
    ]
  }
};

export default function DashboardMVP() {
  const [cedula, setCedula] = useState('');
  const [placa, setPlaca] = useState('');
  const [activeTab, setActiveTab] = useState('perfil');
  const [consultado, setConsultado] = useState(false);
  const [cargando, setCargando] = useState(false);
  const [isDarkMode, setIsDarkMode] = useState(() => {
    const savedTheme = localStorage.getItem('theme');
    return savedTheme === 'dark' || (!savedTheme && window.matchMedia('(prefers-color-scheme: dark)').matches);
  });
  const [errores, setErrores] = useState({ cedula: '', placa: '' });
  
  // Estados para datos reales del backend
  const [datosVehiculo, setDatosVehiculo] = useState(null);
  const [multasReales, setMultasReales] = useState([]);
  const [documentosReales, setDocumentosReales] = useState([]);
  const [historialReal, setHistorialReal] = useState([]);

  const handleCedulaChange = (e) => {
    const valor = e.target.value;
    setCedula(valor);
    
    // Validar en tiempo real si hay contenido
    if (valor.trim()) {
      const validacion = validarCedulaColombiana(valor);
      setErrores(prev => ({ ...prev, cedula: validacion.mensaje }));
    } else {
      setErrores(prev => ({ ...prev, cedula: '' }));
    }
  };

  const handlePlacaChange = (e) => {
    const valor = e.target.value;
    setPlaca(valor);
    
    // Validar en tiempo real si hay contenido
    if (valor.trim()) {
      const validacion = validarPlacaColombiana(valor);
      setErrores(prev => ({ ...prev, placa: validacion.mensaje }));
    } else {
      setErrores(prev => ({ ...prev, placa: '' }));
    }
  };

  const handleConsultar = async () => {
    if (!cedula.trim() || !placa.trim()) {
      alert('Por favor complete ambos campos');
      return;
    }

    // Validar ambos campos antes de proceder
    const validacionCedula = validarCedulaColombiana(cedula);
    const validacionPlaca = validarPlacaColombiana(placa);

    if (!validacionCedula.valida || !validacionPlaca.valida) {
      setErrores({
        cedula: validacionCedula.mensaje,
        placa: validacionPlaca.mensaje
      });
      return;
    }

    // Limpiar errores si todo está bien
    setErrores({ cedula: '', placa: '' });

    setCargando(true);
    
    try {
      // Consulta real a la API - usar URL relativa para que funcione con proxy
      const apiUrl = import.meta.env.VITE_API_URL || '';
      const response = await fetch(`${apiUrl}/api/consulta/${placa}/${cedula}`);
      const data = await response.json();
      
      if (data.success) {
        setConsultado(true);
        
        // Procesar y almacenar los datos reales
        const vehiculoData = data.data;
        setDatosVehiculo(vehiculoData);
        
        // Procesar multas
        const multasProcesadas = vehiculoData.multas.map(multa => ({
          nombre: multa.tipo_infraccion,
          fecha: multa.fecha,
          vencimiento: multa.fecha, // Las multas no tienen vencimiento separado
          valor: `$${multa.monto.toLocaleString()}`,
          estatus: multa.estado
        }));
        setMultasReales(multasProcesadas);
        
        // Procesar documentos
        const documentosProcesados = vehiculoData.documentos.map(doc => ({
          tipo: doc.tipo,
          estado: doc.estado,
          vencimiento: doc.vencimiento,
          valor: doc.valor
        }));
        setDocumentosReales(documentosProcesados);
        
        // Procesar historial
        const historialProcesado = vehiculoData.historial.map(h => ({
          nombre: h.nombre,
          desde: h.desde,
          hasta: h.hasta,
          cedula: h.cedula
        }));
        setHistorialReal(historialProcesado);
        
        console.log('Datos procesados:', {
          vehiculo: vehiculoData,
          multas: multasProcesadas,
          documentos: documentosProcesados,
          historial: historialProcesado
        });
      } else {
        alert(data.message);
      }
    } catch (error) {
      console.error('Error al consultar:', error);
      alert('Error al consultar la información. Verifique que el backend esté funcionando.');
    } finally {
      setCargando(false);
    }
  };

  const handleNuevaConsulta = () => {
    setConsultado(false);
    setCedula('');
    setPlaca('');
    setActiveTab('perfil');
    setErrores({ cedula: '', placa: '' });
    
    // Limpiar datos reales
    setDatosVehiculo(null);
    setMultasReales([]);
    setDocumentosReales([]);
    setHistorialReal([]);
  };

  const toggleTheme = () => {
    const newTheme = !isDarkMode;
    setIsDarkMode(newTheme);
    localStorage.setItem('theme', newTheme ? 'dark' : 'light');
  };

  // Crear datos de documentos dinámicos basados en los datos reales
  const documentosDataDinamico = datosVehiculo ? {
    perfil: {
      nombre: 'Perfil del Propietario Actual',
      tipo: 'propietario',
      datos: {
        cedula: datosVehiculo.propietario.cedula,
        nombre: datosVehiculo.propietario.nombre,
        celular: datosVehiculo.propietario.telefono,
        correo: datosVehiculo.propietario.email,
        licencias: 'A2, B1', // No disponible en el backend
        direccion: datosVehiculo.propietario.direccion,
        fechaRegistro: '2023-01-15' // No disponible en el backend
      }
    },
    soat: {
      nombre: 'SOAT',
      tipo: 'documento',
      vencimiento: datosVehiculo.documentos.find(d => d.tipo === 'SOAT')?.vencimiento || 'N/A',
      valor: datosVehiculo.documentos.find(d => d.tipo === 'SOAT')?.valor || '$150.000',
      estado: datosVehiculo.documentos.find(d => d.tipo === 'SOAT')?.estado || 'N/A',
      detalles: {
        numero: 'SOAT-2024-001',
        aseguradora: 'Seguros Bolívar',
        cobertura: 'Responsabilidad Civil'
      }
    },
    tecnomecanica: {
      nombre: 'Tecnomecánica',
      tipo: 'documento',
      vencimiento: datosVehiculo.documentos.find(d => d.tipo === 'Tecnomecánica')?.vencimiento || 'N/A',
      valor: datosVehiculo.documentos.find(d => d.tipo === 'Tecnomecánica')?.valor || '$180.000',
      estado: datosVehiculo.documentos.find(d => d.tipo === 'Tecnomecánica')?.estado || 'N/A',
      detalles: {
        numero: 'TM-2024-002',
        centro: 'Centro de Diagnóstico Automotor',
        resultado: 'Aprobado'
      }
    },
    impuesto: {
      nombre: 'Impuesto Vehicular',
      tipo: 'documento',
      vencimiento: '2025-12-31',
      valor: '$320.000',
      estado: 'Pendiente',
      detalles: {
        año: '2024',
        periodo: 'Enero - Diciembre',
        descuento: '5% por pago anticipado'
      }
    },
    historial: {
      nombre: 'Historial de Propietarios',
      tipo: 'historial',
      datos: historialReal.length > 0 ? historialReal : [
        { nombre: 'Juan Pérez', desde: '2023', hasta: 'Actual', cedula: '123456789' },
        { nombre: 'Andrea Gómez', desde: '2020', hasta: '2022', cedula: '987654321' },
        { nombre: 'Carlos López', desde: '2018', hasta: '2019', cedula: '456789123' }
      ]
    }
  } : documentosData;

  return (
    <div className={`min-h-screen transition-colors duration-300 ${
      isDarkMode 
        ? 'bg-gray-900 text-gray-100' 
        : 'bg-gray-50 text-gray-800'
    }`}>
      {/* Header */}
      <header className={`shadow-md p-4 flex justify-between items-center transition-colors duration-300 ${
        isDarkMode 
          ? 'bg-gray-800 border-b border-gray-700' 
          : 'bg-white'
      }`}>
        <h1 className="text-2xl font-bold">Consultas Vehiculares</h1>
        <div className="flex items-center gap-4">
          <button 
            onClick={toggleTheme}
            className={`p-2 rounded-lg transition-colors duration-300 ${
              isDarkMode 
                ? 'bg-gray-700 text-yellow-400 hover:bg-gray-600' 
                : 'bg-gray-200 text-gray-600 hover:bg-gray-300'
            }`}
            title={isDarkMode ? 'Cambiar a modo claro' : 'Cambiar a modo oscuro'}
          >
            {isDarkMode ? '☀️' : '🌙'}
          </button>
          <button className={`text-sm transition-colors duration-300 ${
            isDarkMode ? 'text-blue-400 hover:text-blue-300' : 'text-blue-600 hover:text-blue-700'
          }`}>
            Ayuda
          </button>
        </div>
      </header>

      {/* Dashboard Container */}
      <main className="max-w-7xl mx-auto px-4 py-8 grid grid-cols-1 gap-6">
        {/* Formulario de Consulta */}
        <section className={`p-6 rounded-2xl shadow transition-colors duration-300 ${
          isDarkMode 
            ? 'bg-gray-800 border border-gray-700' 
            : 'bg-white'
        }`}>
          <h2 className="text-xl font-semibold mb-4">Buscar Información</h2>
          <div className="grid md:grid-cols-3 gap-4">
            <div>
              <input
                type="text"
                placeholder="Cédula (ej: 12345678)"
                value={cedula}
                onChange={handleCedulaChange}
                className={`border p-2 rounded transition-colors duration-300 w-full ${
                  errores.cedula 
                    ? 'border-red-500 focus:border-red-500' 
                    : isDarkMode 
                      ? 'bg-gray-700 border-gray-600 text-gray-100 placeholder-gray-400 focus:border-blue-400' 
                      : 'bg-white border-gray-300 text-gray-800 placeholder-gray-500 focus:border-blue-500'
                }`}
              />
              {errores.cedula && (
                <p className={`text-xs mt-1 transition-colors duration-300 ${
                  isDarkMode ? 'text-red-400' : 'text-red-600'
                }`}>
                  {errores.cedula}
                </p>
              )}
            </div>
            <div>
              <input
                type="text"
                placeholder="Placa (ej: ABC-123)"
                value={placa}
                onChange={handlePlacaChange}
                className={`border p-2 rounded transition-colors duration-300 w-full ${
                  errores.placa 
                    ? 'border-red-500 focus:border-red-500' 
                    : isDarkMode 
                      ? 'bg-gray-700 border-gray-600 text-gray-100 placeholder-gray-400 focus:border-blue-400' 
                      : 'bg-white border-gray-300 text-gray-800 placeholder-gray-500 focus:border-blue-500'
                }`}
              />
              {errores.placa && (
                <p className={`text-xs mt-1 transition-colors duration-300 ${
                  isDarkMode ? 'text-red-400' : 'text-red-600'
                }`}>
                  {errores.placa}
                </p>
              )}
            </div>
            <div className="flex items-end">
              <button 
                onClick={handleConsultar}
                disabled={cargando || errores.cedula || errores.placa}
                className={`px-4 py-2 rounded text-white transition-colors duration-300 w-full ${
                  cargando || errores.cedula || errores.placa
                    ? 'bg-gray-400 cursor-not-allowed' 
                    : 'bg-blue-600 hover:bg-blue-700'
                }`}
              >
                {cargando ? 'Consultando...' : 'Consultar'}
              </button>
            </div>
          </div>
        </section>

        {/* Mostrar mensaje inicial o resultados */}
        {!consultado ? (
          <section className={`p-8 rounded-2xl text-center transition-colors duration-300 ${
            isDarkMode 
              ? 'bg-gray-800 border border-gray-700' 
              : 'bg-gray-100'
          }`}>
            <div className={`transition-colors duration-300 ${
              isDarkMode ? 'text-gray-300' : 'text-gray-600'
            }`}>
              <h3 className="text-lg font-medium mb-2">¡Bienvenido!</h3>
              <p>Complete los campos de cédula y placa para consultar la información vehicular.</p>
              <p className="text-sm mt-2">Podrá ver multas, documentos, historial de propietarios y más.</p>
            </div>
          </section>
        ) : (
          <>
            {/* Botón para nueva consulta */}
            <section className={`p-4 rounded-2xl border transition-colors duration-300 ${
              isDarkMode 
                ? 'bg-blue-900 border-blue-700' 
                : 'bg-blue-50 border-blue-200'
            }`}>
              <div className="flex justify-between items-center">
                <div className={`text-sm transition-colors duration-300 ${
                  isDarkMode ? 'text-blue-300' : 'text-blue-800'
                }`}>
                  <strong>Consulta realizada:</strong> Cédula {cedula} - Placa {placa}
                </div>
                <button 
                  onClick={handleNuevaConsulta}
                  className={`text-sm underline transition-colors duration-300 ${
                    isDarkMode ? 'text-blue-400 hover:text-blue-300' : 'text-blue-600 hover:text-blue-800'
                  }`}
                >
                  Nueva consulta
                </button>
              </div>
            </section>

            {/* Multas */}
        <section className={`p-6 rounded-2xl shadow transition-colors duration-300 ${
          isDarkMode 
            ? 'bg-gray-800 border border-gray-700' 
            : 'bg-white'
        }`}>
          <h2 className="text-xl font-semibold mb-4">Histórico de Multas</h2>
          <table className="w-full text-sm">
            <thead>
              <tr className={`text-left border-b transition-colors duration-300 ${
                isDarkMode ? 'border-gray-600' : 'border-gray-200'
              }`}>
                <th className="pb-2">Nombre</th>
                <th className="pb-2">Fecha</th>
                <th className="pb-2">Vencimiento</th>
                <th className="pb-2">Valor</th>
                <th className="pb-2">Estatus</th>
              </tr>
            </thead>
            <tbody>
              {(multasReales.length > 0 ? multasReales : multasDummy).map((multa, index) => (
                <tr key={index} className={`border-b transition-colors duration-300 ${
                  isDarkMode ? 'border-gray-600' : 'border-gray-200'
                }`}>
                  <td className="py-2">{multa.nombre}</td>
                  <td className="py-2">{multa.fecha}</td>
                  <td className="py-2">{multa.vencimiento}</td>
                  <td className="py-2">{multa.valor}</td>
                  <td className="py-2">
                    <span
                      className={`px-2 py-1 rounded text-xs ${
                        multa.estatus === 'Pendiente' || multa.estatus === 'PENDIENTE'
                          ? 'bg-red-200 text-red-800'
                          : multa.estatus === 'Pagado' || multa.estatus === 'PAGADA'
                          ? 'bg-green-200 text-green-800'
                          : 'bg-yellow-200 text-yellow-800'
                      }`}
                    >
                      {multa.estatus}
                    </span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </section>

        {/* Estado actual de documentos */}
        <section className={`p-6 rounded-2xl shadow transition-colors duration-300 ${
          isDarkMode 
            ? 'bg-gray-800 border border-gray-700' 
            : 'bg-white'
        }`}>
          <h2 className="text-xl font-semibold mb-4">Documentos del Vehículo</h2>
          
          {/* Tabs Navigation */}
          <div className={`flex border-b mb-4 transition-colors duration-300 ${
            isDarkMode ? 'border-gray-600' : 'border-gray-200'
          }`}>
            {Object.keys(documentosDataDinamico).map((key) => (
              <button
                key={key}
                onClick={() => setActiveTab(key)}
                className={`px-4 py-2 text-sm font-medium border-b-2 transition-colors duration-300 ${
                  activeTab === key
                    ? isDarkMode
                      ? 'border-blue-400 text-blue-400'
                      : 'border-blue-500 text-blue-600'
                    : isDarkMode
                      ? 'border-transparent text-gray-400 hover:text-gray-300'
                      : 'border-transparent text-gray-500 hover:text-gray-700'
                }`}
              >
                {documentosDataDinamico[key].nombre}
              </button>
            ))}
          </div>

          {/* Tab Content */}
          <div className="min-h-[200px]">
            {Object.keys(documentosDataDinamico).map((key) => (
              <div
                key={key}
                className={`${activeTab === key ? 'block' : 'hidden'}`}
              >
                {documentosDataDinamico[key].tipo === 'propietario' && (
                  <div className="grid md:grid-cols-2 gap-4">
                    <div>
                      <h3 className="font-bold text-lg mb-2">{documentosDataDinamico[key].nombre}</h3>
                      <div className="space-y-2 text-sm">
                        <p><strong>Cédula:</strong> {documentosDataDinamico[key].datos.cedula}</p>
                        <p><strong>Nombre:</strong> {documentosDataDinamico[key].datos.nombre}</p>
                        <p><strong>Celular:</strong> {documentosDataDinamico[key].datos.celular}</p>
                        <p><strong>Correo:</strong> {documentosDataDinamico[key].datos.correo}</p>
                        <p><strong>Licencias:</strong> {documentosDataDinamico[key].datos.licencias}</p>
                      </div>
                    </div>
                    <div className="text-sm">
                      <h4 className="font-medium mb-2">Información Adicional:</h4>
                      <div className="space-y-1">
                        <p><strong>Dirección:</strong> {documentosDataDinamico[key].datos.direccion}</p>
                        <p><strong>Fecha de Registro:</strong> {documentosDataDinamico[key].datos.fechaRegistro}</p>
                      </div>
                    </div>
                  </div>
                )}

                {documentosDataDinamico[key].tipo === 'documento' && (
                  <div className="grid md:grid-cols-2 gap-4">
                    <div>
                      <h3 className="font-bold text-lg mb-2">{documentosDataDinamico[key].nombre}</h3>
                      <div className="space-y-2 text-sm">
                        <p><strong>Vencimiento:</strong> {documentosDataDinamico[key].vencimiento}</p>
                        <p><strong>Valor:</strong> {documentosDataDinamico[key].valor}</p>
                        <span className={`inline-block px-2 py-1 text-xs rounded ${
                          documentosDataDinamico[key].estado === 'Activo' || documentosDataDinamico[key].estado === 'VIGENTE'
                            ? 'bg-green-200 text-green-800'
                            : documentosDataDinamico[key].estado === 'VENCIDO'
                            ? 'bg-red-200 text-red-800'
                            : 'bg-yellow-200 text-yellow-800'
                        }`}>
                          {documentosDataDinamico[key].estado}
                        </span>
                      </div>
                    </div>
                    <div className="text-sm">
                      <h4 className="font-medium mb-2">Detalles:</h4>
                      <div className="space-y-1">
                        {Object.entries(documentosDataDinamico[key].detalles).map(([detailKey, value]) => (
                          <p key={detailKey}>
                            <strong>{detailKey.charAt(0).toUpperCase() + detailKey.slice(1)}:</strong> {value}
                          </p>
                        ))}
                      </div>
                    </div>
                  </div>
                )}

                {documentosDataDinamico[key].tipo === 'historial' && (
                  <div>
                    <h3 className="font-bold text-lg mb-4">{documentosDataDinamico[key].nombre}</h3>
                    <div className="space-y-3">
                      {documentosDataDinamico[key].datos.map((propietario, index) => (
                        <div key={index} className={`p-3 rounded-lg transition-colors duration-300 ${
                          isDarkMode ? 'bg-gray-700' : 'bg-gray-50'
                        }`}>
                          <div className="flex justify-between items-start">
                            <div>
                              <p className="font-medium">{propietario.nombre}</p>
                              <p className={`text-sm transition-colors duration-300 ${
                                isDarkMode ? 'text-gray-400' : 'text-gray-600'
                              }`}>
                                Cédula: {propietario.cedula}
                              </p>
                            </div>
                            <div className="text-right text-sm">
                              <p><strong>Desde:</strong> {propietario.desde}</p>
                              <p><strong>Hasta:</strong> {propietario.hasta}</p>
                            </div>
                          </div>
                        </div>
                      ))}
                    </div>
                  </div>
                )}
              </div>
            ))}
          </div>
        </section>


        {/* Configurar Alertas */}
        <section className={`p-6 rounded-2xl shadow transition-colors duration-300 ${
          isDarkMode 
            ? 'bg-gray-800 border border-gray-700' 
            : 'bg-white'
        }`}>
          <h2 className="text-xl font-semibold mb-4">Configurar Alertas</h2>
          <form className="grid md:grid-cols-2 gap-4 text-sm">
            <div>
              <label className={`block mb-1 font-medium transition-colors duration-300 ${
                isDarkMode ? 'text-gray-300' : 'text-gray-700'
              }`}>
                Tipo de alerta
              </label>
              <div className="flex flex-col gap-1">
                <label className={`flex items-center transition-colors duration-300 ${
                  isDarkMode ? 'text-gray-300' : 'text-gray-700'
                }`}>
                  <input type="checkbox" className="mr-2" /> SOAT
                </label>
                <label className={`flex items-center transition-colors duration-300 ${
                  isDarkMode ? 'text-gray-300' : 'text-gray-700'
                }`}>
                  <input type="checkbox" className="mr-2" /> Tecnomecánica
                </label>
                <label className={`flex items-center transition-colors duration-300 ${
                  isDarkMode ? 'text-gray-300' : 'text-gray-700'
                }`}>
                  <input type="checkbox" className="mr-2" /> Impuesto
                </label>
              </div>
            </div>
            <div>
              <label className={`block mb-1 font-medium transition-colors duration-300 ${
                isDarkMode ? 'text-gray-300' : 'text-gray-700'
              }`}>
                Contacto
              </label>
              <input 
                type="text" 
                placeholder="Correo o celular" 
                className={`border p-2 w-full rounded transition-colors duration-300 ${
                  isDarkMode 
                    ? 'bg-gray-700 border-gray-600 text-gray-100 placeholder-gray-400 focus:border-blue-400' 
                    : 'bg-white border-gray-300 text-gray-800 placeholder-gray-500 focus:border-blue-500'
                }`} 
              />
            </div>
            <div className="md:col-span-2">
              <button className={`px-4 py-2 rounded text-white transition-colors duration-300 ${
                isDarkMode 
                  ? 'bg-blue-600 hover:bg-blue-700' 
                  : 'bg-blue-600 hover:bg-blue-700'
              }`}>
                Guardar Alerta
              </button>
            </div>
          </form>
        </section>
          </>
        )}
      </main>
    </div>
  );
}