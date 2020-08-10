% SOLUCIÓN Y TESTS AQUÍ
% rol(Persona, Rol).
rol(homero, civil).
rol(burns, civil).
rol(bart, mafia).
rol(tony, mafia).
rol(maggie, mafia).
rol(nick, medico).
rol(hibbert, medico).
rol(lisa, detective).
rol(rafa, detective).
/*
 Atacar una persona: nos interesa quién es la persona atacada. 
 En cada ronda la mafia elige una persona a quién atacar.
 atacar(Ronda,Persona)

atacar(1,lisa).
atacar(2,rafa).
atacar(3,lisa).
atacar(4,homero).
atacar(5,lisa).
atacar(6,burns).
*/

ronda(1, atacar(lisa)).
ronda(1, salvar(nick, nick)).
ronda(1, salvar(hibbert, lisa)).
ronda(1, investigar(lisa,tony)).
ronda(1, investigar(rafa, lisa)).
ronda(1, eliminar(nick)).

ronda(2, atacar(rafa)).
ronda(2, salvar(hibbert, rafa)).
ronda(2, investigar(lisa,bart)).
ronda(2, investigar(rafa,maggie)).
ronda(2, eliminar(rafa)).

ronda(3, atacar(lisa)).
ronda(3, salvar(hibbert, lisa)).
ronda(3, investigar(lisa,burns)).
ronda(3, eliminar(hibbert)).

ronda(4, atacar(homero)).
ronda(4, investigar(lisa,homero)).
ronda(4, eliminar(tony)).

ronda(5, atacar(lisa)).
ronda(5, investigar(lisa,maggie)).
ronda(5, eliminar(bart)).

ronda(6, atacar(burns)).
/*
1. Modelar las acciones anteriores de forma tal que se pueda expandir la base de conocimiento 
 agregando información de las acciones que se produjeron en cada ronda.  

 b. Deducir las personas que perdieron en una determinada ronda. O sea, aquellas que fueron eliminadas 
 en dicho ronda, ó atacadas por la mafia, salvo que algún médico haya salvado a la persona, en dicha ronda.
*/
pierde(Ronda,Persona):-
    ronda(Ronda, eliminar(Persona)).

pierde(Ronda,Persona):-
    ronda(Ronda,atacar(Persona)),
    not( ronda(Ronda,salvar(_,Persona)) ).


%%% c. Casos de prueba
:- begin_tests(eliminaciones).
    test(eliminado_pierde_la_ronda, nondet):-
        pierde(1, nick).
    test(eliminacion_por_ataque, nondet):-
        pierde(4, homero).
    test(salvado_por_medico, fail):-
        pierde(1, lisa).
    test(salvado_pero_eliminado, nondet):-
        pierde(2, rafa).
    test(ni_eliminado_ni_atacado, fail):-
        pierde(_, maggie).
    test(mas_de_un_eliminado, nondet):-
        pierde(5, bart),
        pierde(5, lisa).
:- end_tests(eliminaciones).

/*
 2.  Dos bandos: Por un lado, los integrantes de la mafia. Y por el otro, el resto de los jugadores.
 El juego termina cuando un bando logra sacar por completo al otro del juego.

 a. Necesitamos conocer los contrincantes de una persona, o sea, los del otro bando. 
 Si la persona pertenece a la mafia, los contrincantes son todos aquellos que no forman parte de la mafia; 
 y viceversa. Esta relación debe ser simétrica.
*/

contrincantes(X, Y):-
    sonContrincantes(X, Y).
contrincantes(X, Y):-
    sonContrincantes(Y, X).

sonContrincantes(Jugador, OtroJugador):-
    rol(Jugador, mafia),
    rol(OtroJugador, _),
    not( rol(OtroJugador, mafia)),
    Jugador \= OtroJugador.

%%% b. Saber si alguien ganó, y en el caso que haya varios ganadores, conocerlos todos. 
% Una persona es ganadora cuando no perdió pero todos sus contrincantes sí.

ganador(Jugador):-
    rol(Jugador,_),
    not( pierde(_,Jugador) ),
    forall(
        contrincantes(Jugador,Contrincante)
    ,  
        pierde(_,Contrincante)
    ).

%%% c. Casos de prueba
:-begin_tests(contrincantes).
    test(contrincantes_de_tony, set(Quien == [homero, burns, nick, hibbert, lisa, rafa])):-
        contrincantes(tony, Quien).

:-end_tests(contrincantes).
:-begin_tests(ganadores).
    test(maggie_es_la_ganadora):-
        ganador(maggie).
:-end_tests(ganadores).
/*
------- RELACION CON INVERSIBILIDAD:
 Esta regla debe ser inversible para que el interprete
 nos pueda encontrar los ganadores. Esto significa que se ligue
 la variable Jugador, con un jugador que tiene un rol, por ende
 esta en nuestro universo cerrado. Ademas, es importante no ligar 
 Contrincante para que tome todos los valores posibles
 y, si bien el not() no es inversible, el jugador queda ligado por rol()
*/


% 3.a  Se pide Saber si un jugador es imbatible.
% Un médico es imbatible cuando siempre salvó a alguien que estaba siendo atacado por la mafia.

imbatible(Medico):-
    rol(Medico,medico),
    forall(ronda(Ronda,salvar(Medico,Persona)), ronda(Ronda,atacar(Persona))).
% Un detective es imbatible cuando ha investigado a todas las personas que pertenecen a la mafia.
imbatible(Detective):-
    rol(Detective, detective),
    forall(rol(Persona,mafia), ronda(_,investigar(Detective,Persona))).

%El resto de las personas nunca son imbatibles.
% Explicar cómo se relacionan los conceptos de inversibilidad y universo cerrado con la solución.

/* 
------- RELACION CON INVERSIBILIDAD Y UNIVERSO CERRADO:
En este caso, al igual que en el anterior, imbatible es inversible, ya que el predicado rol() lo es, 
y es importante que en el forall Persona, siga siendo libre y no llegue ligada.
En cuanto a universo cerrado, "el resto de las personas nunca son imbatibles", 
en nuestra base de conocimiento, lo que no existe se considera falso,
y al tener definidos los imbatibles, los que no están no lo serán. 
Por lo tanto, no hace falta incorporarlos debido al principio de universo cerrado
*/

%%% b. Casos de prueba
:-begin_tests(imbatibles).
    test(imbatibles, set(Quien == [hibbert,lisa])):-
        imbatible(Quien).
    test(medico_no_es_imbatible, fail):-
        imbatible(nick).
    test(detective_no_imbatible, fail):-
        imbatible(rafa).
    test(civil_no_es_imbatible, fail):-
        imbatible(homero).
:-end_tests(imbatibles).


% 4. Implementar los predicados necesarios para:

%%% a. (ambos integrantes) Deducir las personas que siguen en juego al comenzar una determinada ronda, 
% o sea, las que todavía no perdieron (sin importar si pierde en dicha ronda o posterior).
    % sigueEnJuego(Jugador,Ronda)

sigueEnJuego(Jugador,Ronda):-
    rol(Jugador,_),
    ronda(Ronda,_), %Esto es para ligar que es un numero
    forall(
        (
            ronda(RondaAnterior,_), %Esto es para ligar que es un numero
            RondaAnterior < Ronda
        )
        ,
        (
            not( pierde(RondaAnterior, Jugador))
        )
    ).


%%% b. (integrante 1) Conocer cuáles son las rondas interesantes que tuvo la partida. 

cantidadEnJuego(Ronda, Rol, Cantidad):-
    ronda(Ronda,_),
    rol(_,Rol),
    findall(Jugador, (sigueEnJuego(Jugador, Ronda), rol(Jugador,Rol)), JugadoresPre),
    list_to_set(JugadoresPre, Jugadores),
    length(Jugadores, Cantidad).

participantesEnRonda(Ronda, Cantidad):-
    findall(Jugador, sigueEnJuego(Jugador, Ronda), JugadoresPre),
    list_to_set(JugadoresPre, Jugadores),
    length(Jugadores, Cantidad).

% Una ronda es interesante si en dicha ronda siguen más de 7 personas en juego. 
esRondaInteresante(Ronda):-
    ronda(Ronda,_),
    participantesEnRonda(Ronda, Cantidad),
    Cantidad > 7.

% También es interesante cuando quedan en juego menos o igual cantidad de personas 
% que la cantidad inicial de la mafia.
esRondaInteresante(Ronda):-
    ronda(Ronda,_),
    participantesEnRonda(Ronda, Cantidad),
    cantidadEnJuego(1,mafia,CantidadDeMafia),
    Cantidad =< CantidadDeMafia.

%%% c. (integrante 2) Saber quiénes vivieron el peligro, 


% Se dice que una ronda es peligrosa cuando la cantidad de personas en juego es 3 veces la cantidad de 
% civiles con los que empezó la partida.

peligrosa(Ronda):-
    ronda(Ronda,_),
    participantesEnRonda(Ronda,CantPersonas),
    cantidadEnJuego(1,civil,CantCiviles),
    CantPersonas is 3*CantCiviles.

% vivio el peligro que son los civiles o detectives que jugaron alguna ronda peligrosa. 
% repite logica, ver.
vivioElPeligro(Jugador):-
    %rol(Jugador,_),
    sigueEnJuego(Jugador,Ronda),
    not(rol(Jugador,mafia)),
    not(rol(Jugador,medico)),
    peligrosa(Ronda).
    
%%% d. Casos de prueba
:-begin_tests(siguen).
    test(sigue_aunque_pierda_luego,nondet):-
        sigueEnJuego(rafa,2).
    test(no_sigue_por_perder_antes, fail):-
        sigueEnJuego(nick,4).
    test(llegan_a_la_ultima, set(Quien == [maggie, burns])):-
        sigueEnJuego(Quien,6).
    test(todos_en_el_principio, set(Quien == [lisa, bart, nick, hibbert, homero, burns, maggie, tony, rafa])):-
        sigueEnJuego(Quien,1).
        
:-end_tests(siguen).

:-begin_tests(interesantes).
    test(es_ronda_interesante, set(Ronda == [1,2,6])):-
        esRondaInteresante(Ronda).
    test(no_es_interesante_hay_7_personas_en_juego, fail):-
        esRondaInteresante(3).
        
:-end_tests(interesantes).

:-begin_tests(vivieron_peligro).
    test(civil_vive_peligro_en_ronda_peligrosa, nondet):-
        vivioElPeligro(homero).
    test(detective_vive_peligro_en_ronda_peligrosa, nondet):-
        vivioElPeligro(lisa).
    test(mafia_no_vive_peligro, fail):-
        vivioElPeligro(tony).
    test(no_vive_peligro_si_no_juega_ronda_peligrosa, fail):-
        vivioElPeligro(rafa).
    test(vivieron_el_peligro, set(Quien == [lisa,burns,homero])):-
        vivioElPeligro(Quien).
:-end_tests(vivieron_peligro).

% Algo que deberá saber son las personas responsables y afectadas de una determinada acción:
%accion(ataque).
%accion(eliminacion).
%accion(salvataje).
%accion(investigacion).

leHizoAlgo(Responsable,Afectade):-
    ronda(_,Accion),
    responsabilidad(_, Accion, Responsable,Afectade).

responsabilidad(Ronda, Accion, Responsable, Afectade):-
    %accion(Accion),
    %ronda(Ronda,_),
    ronda(Ronda,Accion),
    %rol(Responsable,_),
    %rol(Afectade,_),
    sigueEnJuego(Responsable,Ronda),
    sigueEnJuego(Afectade,Ronda),
    Responsable \= Afectade,
    responsableDe(Ronda, Accion, Responsable, Afectade).

% Atacar una persona: las personas responsables son todas las que conforman la mafia. 
% La persona afectada es la atacada.

%responsableDe(Ronda, ataque, Responsable, Afectade):-
responsableDe(Ronda, atacar(Afectade), Responsable, Afectade):-
    rol(Responsable,mafia),
    ronda(Ronda,atacar(Afectade)).

% Salvar una persona: la persona responsable es el médico, la afectada es la persona salvada.
%responsableDe(Ronda, salvataje, Medico, Afectade):-
responsableDe(Ronda,salvar(Medico,Afectade), Medico, Afectade):-
    ronda(Ronda,salvar(Medico,Afectade)).

% Investigar a una persona: la persona responsable es el detective que investiga, la afectada es la persona investigada.
%responsableDe(Ronda, investigacion, Detective, Afectade):-
responsableDe(Ronda, investigar(Detective,Afectade), Detective, Afectade):-
    ronda(Ronda,investigar(Detective,Afectade)).

% Eliminar a una persona: las personas responsables son todos los contrincantes (punto 2.a) 
% de la persona eliminada. La persona afectada es la eliminada.
%responsableDe(Ronda, eliminacion, Responsable, Afectade):-
responsableDe(Ronda, eliminar(Afectade), Responsable, Afectade):-
    ronda(Ronda, eliminar(Afectade)),
    contrincantes(Afectade,Responsable).


% 5.a Conocer los jugadores profesionales, que son aquellos que le hicieron algo a todos sus contrincantes, 
% o sea que las acciones de las que el profesional es responsable terminaron afectando a todos sus contrincantes.

profesional(Jugador):-
    rol(Contrincante,_),
    forall(contrincantes(Jugador,Contrincante), leHizoAlgo(Jugador,Contrincante) ).

:-begin_tests(profesional).
    test(civil_vive_peligro_en_ronda_peligrosa, nondet):-
        vivioElPeligro(homero).
    test(detective_vive_peligro_en_ronda_peligrosa, nondet):-
        vivioElPeligro(lisa).
    test(mafia_no_vive_peligro, fail):-
        vivioElPeligro(tony).
    test(no_vive_peligro_si_no_juega_ronda_peligrosa, fail):-
        vivioElPeligro(rafa).
    test(vivieron_el_peligro, set(Quien == [lisa,burns,homero])):-
        vivioElPeligro(Quien).
:-end_tests(profesional).


% 5.b Encontrar una “estrategia” que se haya desenvuelto en la partida. 




% Una estrategia es una serie de acciones que se desarrollan a lo largo de la partida y deben cumplir que:
% La estrategia está conformada por acciones, correspondientes a una acción por cada ronda de la partida.
%Las acciones sucedieron en orden durante la partida.
%Las acciones están encadenadas, lo que significa que la persona afectada por la acción anterior 
%es la responsable de la siguiente.
% Una estrategia debe cumplir, además, que comienza con una acción de la primera ronda 
% y termina con una de la última.

cantidadDeRondas(Cantidad):-
    findall(Ronda, ronda(Ronda,_), RondasPre),
    list_to_set(RondasPre,Rondas),
    length(Rondas,Cantidad).



estrategia([PrimeraAccion, SegundaAccion| UltimasAcciones ]):-
    ronda(RondaSiguiente,_),
    cantidadDeRondas(TotalRondas),
    RondaSiguiente =< TotalRondas,
    ronda(Ronda,_),
    RondaSiguiente is Ronda +1,
    sigueEnJuego(PrimerResponsable,Ronda),
    sigueEnJuego(SegundoAfectado,RondaSiguiente),
    responsabilidad(Ronda, PrimeraAccion, PrimerResponsable, Afectado),
    responsabilidad(RondaSiguiente, SegundaAccion, Afectado, SegundoAfectado),
    estrategia(UltimasAcciones).

% Esto está devolviendo el caso base (como lo pense yo), una lista de acciones, lo de los functores funciona.
% El problema está en la recursividad de arriba, no se como pensarla. si ir de la primera ronda a la ultima, 
% o ir al reves. Y como ir pasando la lista por argumento. Seguro por eso está fallando.

estrategia([UltimaAccion]):-
    cantidadDeRondas(RondaFinal),
    rol(Afectado,_),
    rol(Responsable,_),
    responsabilidad(RondaFinal,UltimaAccion,Responsable,Afectado).

    
/* La mafia ataca a Lisa. (Primera ronda)
Lisa investiga a Bart. (Segunda ronda, Lisa es la afectada por la acción anterior y la responsable de esta acción)
La mafia vuelve a atacar a Lisa. (Tercera ronda, Bart es afectado por la acción anterior y como Bart pertenece a la mafia es un responsable de esta acción)
Lisa investiga a Homero. (Cuarta ronda, Lisa es la afectada por la acción anterior y la responsable de esta acción)
Bart es eliminado. (Quinta ronda, Homero es afectado por la acción anterior y como Homero es contrincante de bart es un responsable de esta acción)
La mafia ataca a Burns. (Sexta y última ronda, Bart es afectado por la acción anterior y como Bart pertenece a la mafia es un responsable de esta acción)

 */





