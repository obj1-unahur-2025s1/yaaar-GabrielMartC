class BarcoPirata{
    var property misionActual
    const property tripulantes = #{}
    var property capacidad 

    method puedeRealizarMision(unaMision) = unaMision.barcoCumpleRequisitos(self) 

    method tieneSuficienteTripulacion() =  tripulantes.size() >= capacidad * 0.9

    method algunTripulanteTieneObjeto(unObjeto) = tripulantes.any({t => t.items().contains(unObjeto)})

    method cantidadTripulantes() = tripulantes.size()


    method esVulnerable(unBarco) = unBarco.cantidadTripulantes() / 2 >= self.cantidadTripulantes() 

    method saqueadoPor(unPirata) = unPirata.pasadoDeGrog()

    method estanTodosPasadosDeGrog() = tripulantes.all({t => t.pasadoDeGrog()})


    //2
    method agregarTripulate(unPirata){
        if(capacidad > self.cantidadTripulantes() && misionActual.pirataCumpleRequisitos(unPirata)){
            tripulantes.add(unPirata)
        }
    }

    //3
    method cambiarMision(nuevaMision){
        misionActual = nuevaMision
        tripulantes.removeAll(self.tripulantesNoCalifican(nuevaMision))

    }

    method tripulantesNoCalifican(unaMision) = tripulantes.filter({t => unaMision.pirataCumpleRequisitos(t)}) //retorna un subconjunto

    //4
    method anclarEnCiudad(unaCiudad){
        tripulantes.forEach({t => t.tomarGrogYGastarMoneda()})
        tripulantes.remove(self.tripulanteMasEbrio())
        unaCiudad.sumarUnHabitante()

    }

    method tripulanteMasEbrio() = tripulantes.max({t => t.nivelEbriedad()})

    //5
    method esTemible() = self.puedeRealizarMisionAsignada()

    method puedeRealizarMisionAsignada() = misionActual.barcoCumpleRequisitos(self)

    //6 modelado en Pirata
    //7.a
    method cantTripulantesPasadosDeGrog() = tripulantes.count({t => t.pasadoDeGrog()})

    //7.b
    method itemsDeTripPasadosDeGrog(){
        const conjuntoItems = #{}

        self.tripulantesPasadosDeGrog().forEach({t => self.agregarItemsAConjunto(t.items(), conjuntoItems)  })

        return conjuntoItems
    }

    method tripulantesPasadosDeGrog() = tripulantes.filter({t => t.pasadoDeGrog()})

    method agregarItemsAConjunto(listaItems,unConjunto){
        return listaItems.forEach({item => unConjunto.add(item)})
    }

    //7.c 
    method tripPasadoDeGrogConMasDinero() = self.tripulantesPasadosDeGrog().max({t => t.monedas()})


    //8
    method tripulanteQueInvitoAMasGente() = tripulantes.max({t => self.cantInvitacionesDeTripulante(t)})

    method cantInvitacionesDeTripulante(unTripulante){
        return tripulantes.count({ t => t.quienLoInvito() == unTripulante})
    }
}

class Pirata{
    const property items = []
    var nivelEbriedad 
    var property monedas
    const property quienLoInvito //otro Pirata

    method nivelEbriedad() = nivelEbriedad 

    method esUtilParaMision(unaMision) = unaMision.pirataCumpleRequisitos(self)

    method seAnimaASaquearA(unaVictima) = unaVictima.puedeSerSaqueadoPor(self)

    method pasadoDeGrog() = nivelEbriedad >= 90

    method tomarGrogYGastarMoneda(){
        nivelEbriedad += 5
        monedas = (monedas - 1).max(0)
    }

    method esEspia() = !self.pasadoDeGrog() && items.contains("PermisoCorona")

}

class Mision{

    method barcoCumpleRequisitos(unBarco) = unBarco.tieneSuficienteTripulacion()

    method pirataCumpleRequisitos(unPirata){}

}

class BusquedaTesoro inherits Mision{

    method tieneItemsDelTesoro(unPirata)= 
            unPirata.items().contains("brujula") || 
            unPirata.items().contains("mapa") ||
            unPirata.items().contains("botellaGrog")

    override method barcoCumpleRequisitos(unBarco) = super(unBarco) && unBarco.algunTripulanteTieneObjeto("llaveCofre")

    override method pirataCumpleRequisitos(unPirata) = self.tieneItemsDelTesoro(unPirata) && unPirata.monedas() <= 5

}

class ConvertirseLeyenda inherits Mision{
    const itemObligatorio 

    override method pirataCumpleRequisitos(unPirata) = unPirata.items().size() >= 10 && unPirata.items().contains(itemObligatorio)

}

class Saqueo inherits Mision{
    var property victima //BarcoPirata, CiudadCostera

    override method pirataCumpleRequisitos(unPirata) = unPirata.monedas() < cantidadMonedas.valor() && victima.saqueadoPor(unPirata)

    override method barcoCumpleRequisitos(unBarco) = super(unBarco) && victima.esVulnerableAlBarco(unBarco)

}

object cantidadMonedas{
    var property valor = 10
}

class CiudadCostera{
    var property habitantes

    method esVulnerable(unBarco) = habitantes * 0.4 <= unBarco.cantidadTripulantes() || unBarco.estanTodosPasadosDeGrog()

    method saqueadoPor(unPirata) = unPirata.pasadoDeGrog()

    method sumarUnHabitante(){
        habitantes += 1
    }
}