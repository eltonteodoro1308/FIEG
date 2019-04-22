#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} LogCustom
Grava o LOG de executação de cada fonte.

@type function
@author Thiago Rasmussen
@since 07/02/2019
@version P12.1.23

@obs Desenvolvimento FIEG

@history 21/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

User Function LogCustom()

Local cDate
Local cTime
Local cDataBase
Local cFunName
Local cGetBuild_AS
Local cGetBuild_SC
Local cGetComputerName
Local cLogUserName
Local cGetClientIP
Local cGetServerIP
Local cGetEnvServer
Local cUser
Local _MV_XLOGCUS := SuperGetMV("MV_XLOGCUS")

IF _MV_XLOGCUS
	cDate            := Dtos(Date())
	cTime            := Time()
	cDataBase        := Dtos(dDataBase)
	cFunName         := FunName()
	cGetBuild_AS     := GetBuild(.F.)
	cGetBuild_SC     := GetBuild(.T.)
	cGetComputerName := GetComputerName()
	cLogUserName     := LogUserName()
	cGetClientIP     := GetClientIP()
	cGetServerIP     := GetServerIP()
	cGetEnvServer    := GetEnvServer()
	cUser            := __cUserID
	
	_SQL := "INSERT INTO ZZZ999 VALUES(" + Chr(39) + cDate 			  + Chr(39) + ",";
	                                     + Chr(39) + cTime 			  + Chr(39) + ","; 
	                                     + Chr(39) + cDataBase 		  + Chr(39) + ","; 
	                                     + Chr(39) + cFunName 		  + Chr(39) + ","; 
	                                     + Chr(39) + cGetBuild_AS 	  + Chr(39) + ","; 
	                                     + Chr(39) + cGetBuild_SC 	  + Chr(39) + ","; 
	                                     + Chr(39) + cGetComputerName + Chr(39) + ","; 
	                                     + Chr(39) + cLogUserName 	  + Chr(39) + ","; 
	                                     + Chr(39) + cGetClientIP 	  + Chr(39) + ","; 
	                                     + Chr(39) + cGetServerIP 	  + Chr(39) + ","; 
	                                     + Chr(39) + cGetEnvServer 	  + Chr(39) + ",";
	                                     + Chr(39) + cUser 			  + Chr(39) + ","; 
	                                     + Chr(39) + '' 			  + Chr(39) + ")"
	
	If TCSQLExec(_SQL) < 0
		Return MsgStop("TCSQLError() " + TCSQLError())
	EndIf                                      
EndIf
	
Return
