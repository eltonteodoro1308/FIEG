#INCLUDE "PROTHEUS.CH"

User Function SICTBA03()
/*/f/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
<Descricao> : Modulo de Contabilidade Gerencial. Processamento do De/Para das Entidades Contแbeis
<Autor> : Joao Carlos A. Neto
<Data> : 09/12/2013
<Parametros> :
<Retorno> : Nil
<Processo> : De/Para das entidades contแbeis
<Rotina> : Contabilidade
<Tipo> (Menu,Trigger,Validacao,Ponto de Entrada,Genericas,Especificas ) : P
<Obs> :
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/

Local oDlg

MV_PAR01 := "2000"
MV_PAR05 := 1      
cEntid   := "Conta Contแbil"
                                                   
Proc_Perg()

DEFINE MSDIALOG oDlg FROM  96,9 TO 320,612 TITLE OemToAnsi("DE/PARA Contแbil") PIXEL

@ 11,6 TO 90,287 LABEL "" OF oDlg  PIXEL
@ 16, 15 SAY OemToAnsi("Esta rotina tem como objetivo executar os DE/PARA das entidades") SIZE 268, 8 OF oDlg PIXEL
@ 26, 15 SAY OemToAnsi("de Contas Contแbeis, Centros de Custos, Itens Contแbeis e Classes") SIZE 268, 8 OF oDlg PIXEL
@ 36, 15 SAY OemToAnsi(" de Valores com base no cadastro de DE/PARA elaborado pela GECON") SIZE 268, 8 OF oDlg PIXEL
@ 46, 15 SAY OemToAnsi("") SIZE 268, 8 OF oDlg PIXEL
@ 56, 15 SAY OemToAnsi("Importante: Certifique-se de que todas as amarra็๕es contแbeis tenham sido realizadas.") SIZE 268, 8 OF oDlg PIXEL

DEFINE SBUTTON FROM 93, 193 TYPE 5 ACTION Proc_Perg() ENABLE OF oDlg
DEFINE SBUTTON FROM 93, 223 TYPE 1 ACTION (MsAguarde( {|| Proc_DePara(oDlg)},"Aguarde","Executando o DE/PARA...",.T. ),oDlg:End()) ENABLE OF oDlg
DEFINE SBUTTON FROM 93, 253 TYPE 2  ACTION oDlg:End() ENABLE OF oDlg

ACTIVATE MSDIALOG oDlg CENTERED

Return


Static Function Proc_DePara(oDlg)
/*/f/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
<Descricao> : Modulo de Contabilidade Gerencial. Processamento do De/Para das Entidades Contแbeis
<Autor> : Joao Carlos A. Neto
<Data> : 09/12/2013
<Parametros> :
<Retorno> : Nil
<Processo> : De/Para das entidades contแbeis
<Rotina> : Contabilidade
<Tipo> (Menu,Trigger,Validacao,Ponto de Entrada,Genericas,Especificas ) : P
<Obs> :
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/
Local nHdl := 0
Local lFim := .F.
Local _MSG := ''
Local _AUX := ''

cArqName:= "\DE_PARA\LOG_DE_PARA__" + DTOS(DATE()) + "__" + SUBSTR(TIME(),1,2) + "_" + SUBSTR(TIME(),4,2) + "_" + SUBSTR(TIME(),7,2) + ".TXT"
nHdl:= FCreate(cArqName)
MV_PAR05 := ALLTRIM(STR(MV_PAR05))      

cEntid := ""
DO CASE
  	CASE MV_PAR05 == "1"
  		cEntid := "Conta Contแbil"
  	CASE MV_PAR05 == "2"
  		cEntid := "Centro de Custo"
  	CASE MV_PAR05 == "3"
  		cEntid := "Item Contแbil"
  	CASE MV_PAR05 == "4"
  		cEntid := "Classe de Valor"
ENDCASE

FWrite(nHdl,"Parโmetros:" + CHR(13)+CHR(10))
FWrite(nHdl," - Exercํcio Contแbil.......? " + MV_PAR01 + CHR(13)+CHR(10))
FWrite(nHdl," - Centro de Custo..........? " + MV_PAR02 + CHR(13)+CHR(10))
FWrite(nHdl," - Item Contแbil............? " + MV_PAR03 + CHR(13)+CHR(10))
FWrite(nHdl," - Conta Contแbil...........? " + MV_PAR04 + CHR(13)+CHR(10))
FWrite(nHdl," - Executa DE/PARA por......? " + cEntid + CHR(13)+CHR(10))
FWrite(nHdl," - Processa Solicita็ใo.....? " + IIF(MV_PAR06 == 1, "Sim", "Nใo") + CHR(13)+CHR(10))
FWrite(nHdl," - Processa Pedido..........? " + IIF(MV_PAR07 == 1, "Sim", "Nใo") + CHR(13)+CHR(10))
FWrite(nHdl," - Procesa Pr้-nota.........? " + IIF(MV_PAR08 == 1, "Sim", "Nใo") + CHR(13)+CHR(10))
FWrite(nHdl," - Processa Contrato........? " + IIF(MV_PAR09 == 1, "Sim", "Nใo") + CHR(13)+CHR(10))
FWrite(nHdl," - Processa Medi็ใo.........? " + IIF(MV_PAR10 == 1, "Sim", "Nใo") + CHR(13)+CHR(10))
FWrite(nHdl," - Processa Banco...........? " + IIF(MV_PAR11 == 1, "Sim", "Nใo") + CHR(13)+CHR(10))
FWrite(nHdl," - Processa Contas a Receber? " + IIF(MV_PAR12 == 1, "Sim", "Nใo") + CHR(13)+CHR(10))
FWrite(nHdl," - Processa Contas a Pagar..? " + IIF(MV_PAR13 == 1, "Sim", "Nใo") + CHR(13)+CHR(10))
FWrite(nHdl,"" + CHR(13)+CHR(10))

FWrite(nHdl,"LOG:" + CHR(13)+CHR(10))
FWrite(nHdl," - Empresa..................: " + xFilial("ZZ0") + CHR(13)+CHR(10))
FWrite(nHdl," - Usuแrio..................: " + UsrFullName(__CUSERID) + CHR(13)+CHR(10))
FWrite(nHdl," - Data.....................: " + DtoC(DATE()) + CHR(13)+CHR(10))
FWrite(nHdl," - Hora.....................: " + TIME() + CHR(13)+CHR(10))
FWrite(nHdl,"" + CHR(13)+CHR(10))

DbSelectArea("ZZ0")

//ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
//บ Remover as redundโncias para a mesma entidade                             บ
//ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
IF Select("QRY") > 0
	DbSelectArea("QRY")
	DbCloseArea()
ENDIF

cQuery := +;
"SELECT ZZ0_FILIAL, ZZ0_EXERC, ZZ0_ENTID, ZZ0_EN_ATU, ZZ0_EN_NEW, MIN(R_E_C_N_O_) AS R_E_C_N_O_, COUNT(*) FROM " + RetSqlName("ZZ0") + " ZZ0 WITH (NOLOCK) " + CRLF +;
"WHERE ZZ0.D_E_L_E_T_ = ' ' " + CRLF +;
"AND ZZ0_FILIAL = '"+xFilial("ZZ0")+"' " + CRLF +;
"AND ZZ0_EXERC = '"+MV_PAR01+"' " + CRLF +;
"AND ZZ0_ENTID = '"+MV_PAR05+"' " + CRLF +;
"AND ZZ0_PROCES = '1' " + CRLF +;
"GROUP BY ZZ0_FILIAL, ZZ0_EXERC, ZZ0_ENTID, ZZ0_EN_ATU, ZZ0_EN_NEW " + CRLF +;
"HAVING COUNT(*) > 1"
DbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), "QRY", .T., .T.)

FWrite(nHdl,cQuery + CHR(13)+CHR(10))
FWrite(nHdl,"" + CHR(13)+CHR(10))

DbSelectArea("QRY")
DbGoTop()

WHILE !EOF()
	cQuery := "UPDATE "+RetSqlName("ZZ0")+" SET ZZ0_PROCES = '2' WHERE ZZ0_FILIAL = '"+ZZ0_FILIAL+"' AND ZZ0_EXERC = '"+ZZ0_EXERC+"' AND ZZ0_ENTID = '"+ZZ0_ENTID+"' AND ZZ0_EN_ATU = '"+ZZ0_EN_ATU+"' AND ZZ0_EN_NEW = '"+ZZ0_EN_NEW+"' AND R_E_C_N_O_ <> "+ALLTRIM(STR(R_E_C_N_O_))+" 
	FWrite(nHdl,cQuery + CHR(13)+CHR(10))
	TcSqlExec(cQuery)
			
	DbSkip()
END	
DbCloseArea()		
FWrite(nHdl,"" + CHR(13)+CHR(10))

//ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
//บ Verifica se exitem processos de DE/PARA em aberto para serem processados  บ
//ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
cQuery := +;
"SELECT ZZ0_FILIAL, ZZ0_EXERC, ZZ0_ENTID, ZZ0_EN_ATU, ZZ0_EN_NEW, COUNT(*) nQTD FROM " + RetSqlName("ZZ0") + " ZZ0 WITH (NOLOCK) " + CRLF +;
"WHERE ZZ0.D_E_L_E_T_ = ' ' " + CRLF +;
"AND ZZ0_FILIAL = '"+xFilial("ZZ0")+"' " + CRLF +;
"AND ZZ0_EXERC = '"+MV_PAR01+"' " + CRLF +;
"AND ZZ0_ENTID = '"+MV_PAR05+"' " + CRLF +;
"AND ZZ0_PROCES = '1' " + CRLF +;
"GROUP BY ZZ0_FILIAL, ZZ0_EXERC, ZZ0_ENTID, ZZ0_EN_ATU, ZZ0_EN_NEW " + CRLF +;
"ORDER BY ZZ0_FILIAL, ZZ0_ENTID, ZZ0_EN_ATU "
DbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), "QRY", .T., .T.)

FWrite(nHdl,cQuery + CHR(13)+CHR(10))
FWrite(nHdl,"" + CHR(13)+CHR(10))

DbSelectArea("QRY")
DbGoTop()
IF nQTD <= 0
	MsgInfo("Nใo existe nenhum DE/PARA de " + cEntid + " cadastrado para entidade " + ALLTRIM(xFilial("ZZ0")) + " para o ano " + MV_PAR01 + ".","Aten็ใo")
	Return
ENDIF      

WHILE !EOF()
	FWrite(nHdl,"CADASTRO DE DE/PARA | "+ALLTRIM(ZZ0_FILIAL)+" | "+ZZ0_EXERC+" | "+cEntid+" | "+ALLTRIM(ZZ0_EN_ATU)+" | "+ALLTRIM(ZZ0_EN_NEW)+ CHR(13)+CHR(10))
	DbSkip()
END	
DbCloseArea()		
FWrite(nHdl,"" + CHR(13)+CHR(10))

Begin Transaction
//ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
//บ Solicita็ใo de Compra                                            บ
//ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
IF MV_PAR06 == 1
	cQuery := +;
	"SELECT C1_FILIAL, C1_ITEM, C1_NUM, C1_EMISSAO, C1_CONTA, C1_CC, C1_ITEMCTA, C1_CLVL, ZZ0_ENTID, ZZ0_EN_ATU, ZZ0_EN_NEW, SC1.R_E_C_N_O_ " + CRLF +;
	"FROM "+RetSqlName("SC1")+ " SC1 WITH (NOLOCK),"+RetSqlName("ZZ0")+ " ZZ0 WITH (NOLOCK) " + CRLF +;
	"WHERE SC1.D_E_L_E_T_ = ' ' " + CRLF +;
	"AND ZZ0.D_E_L_E_T_ = ' ' " + CRLF +;  
	"AND SUBSTRING(C1_FILIAL,1,4) = '"+SubString(xFilial("SC1"),1,4)+"' " + CRLF +;
	"AND C1_RESIDUO <> 'S' " + CRLF +;
	"AND C1_QUANT > C1_QUJE " + CRLF +;
	"AND YEAR(C1_EMISSAO) >= "+ALLTRIM(STR(VAL(MV_PAR01) - 1))+" " + CRLF +;
	"AND C1_FLAGGCT <> '1' " + CRLF +;
	"AND ZZ0_EXERC = '"+MV_PAR01+"' " + CRLF +;
	"AND ZZ0_ENTID = '"+MV_PAR05+"' " + CRLF +;
	"AND ZZ0_PROCES = '1' " + CRLF +;
	"AND SUBSTRING(ZZ0_FILIAL,1,4) = SUBSTRING(C1_FILIAL,1,4) "
	DO CASE
	  	CASE MV_PAR05 == "1"
	  		cQuery += CRLF + "AND C1_CONTA = ZZ0_EN_ATU "
	  	CASE MV_PAR05 == "2"
	  		cQuery += CRLF + "AND C1_CC = ZZ0_EN_ATU "
	  	CASE MV_PAR05 == "3"
	  		cQuery += CRLF + "AND C1_ITEMCTA = ZZ0_EN_ATU "
	  	CASE MV_PAR05 == "4"
	  		cQuery += CRLF + "AND C1_CLVL = ZZ0_EN_ATU "
	ENDCASE
	IF !EMPTY(MV_PAR02)
		cQuery += CRLF + "AND C1_CC = '"+MV_PAR02+"' "
    ENDIF
	IF !EMPTY(MV_PAR03)
		cQuery += CRLF + "AND C1_ITEMCTA = '"+MV_PAR03+"' "
    ENDIF
	IF !EMPTY(MV_PAR04)
		cQuery += CRLF + "AND C1_CONTA = '"+MV_PAR04+"' "
    ENDIF
    
	cQuery += CRLF + "ORDER BY C1_FILIAL"
	DbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), "QRY", .T., .T.)
	Count to nCount
	TcSetField("QRY", "C1_EMISSAO", "D", 08, 0)

	_MSG += ALLTRIM(STR(nCount)) + ' registro(s) de solicita็ใo de compra' + CRLF
		
	FWrite(nHdl,"=========================================================================================================================================================================" + CHR(13)+CHR(10) )
	FWrite(nHdl,cQuery + CHR(13)+CHR(10))
	FWrite(nHdl," " + CHR(13)+CHR(10) )
	
	IF nCount > 0
		DbSelectArea("QRY")
		DbGoTop()
		While !Eof()
			cEntid := ""
		    If ZZ0_ENTID == '1'
		    	cEntid := "Conta Contabil"
				FWrite(nHdl,"SOLICITAวีES DE COMPRAS | "+C1_FILIAL+" | "+C1_NUM+" "+C1_ITEM+" | "+Dtoc(C1_EMISSAO)+" | "+cEntid+" | "+C1_CONTA+" | "+ZZ0_EN_NEW+" | "+ALLTRIM(STR(R_E_C_N_O_)) + CHR(13)+CHR(10) )
		    Elseif ZZ0_ENTID == '2'
		    	cEntid := "Centro de Custo"
				FWrite(nHdl,"SOLICITAวีES DE COMPRAS | "+C1_FILIAL+" | "+C1_NUM+" "+C1_ITEM+" | "+Dtoc(C1_EMISSAO)+" | "+cEntid+" | "+C1_CC+" | "+ZZ0_EN_NEW+" | "+ALLTRIM(STR(R_E_C_N_O_)) + CHR(13)+CHR(10) )
		    Elseif ZZ0_ENTID == '3'
		    	cEntid := "Item Contabil"
				FWrite(nHdl,"SOLICITAวีES DE COMPRAS | "+C1_FILIAL+" | "+C1_NUM+" "+C1_ITEM+" | "+Dtoc(C1_EMISSAO)+" | "+cEntid+" | "+C1_ITEMCTA+" | "+ZZ0_EN_NEW+" | "+ALLTRIM(STR(R_E_C_N_O_)) + CHR(13)+CHR(10) )
		    Elseif ZZ0_ENTID == '4'
		    	cEntid := "Classe de Valor"
				FWrite(nHdl,"SOLICITAวีES DE COMPRAS | "+C1_FILIAL+" | "+C1_NUM+" "+C1_ITEM+" | "+Dtoc(C1_EMISSAO)+" | "+cEntid+" | "+C1_CLVL+" | "+ZZ0_EN_NEW+" | "+ALLTRIM(STR(R_E_C_N_O_)) + CHR(13)+CHR(10) )
			Endif
			DbSkip()
		End	
		FWrite(nHdl,"" + CHR(13)+CHR(10) )
		DbCloseArea()		
		
		cQuery := +;
		"INSERT INTO ZZ1010(ZZ1_FILIAL,ZZ1_EXERC,ZZ1_ENTID,ZZ1_EN_ATU,ZZ1_EN_NEW,ZZ1_DATHOR,ZZ1_TABELA,ZZ1_RECNO,ZZ1_DATA,ZZ1_HORA,ZZ1_USERGI) " + CRLF +;
		"SELECT ZZ0_FILIAL, ZZ0_EXERC, ZZ0_ENTID, ZZ0_EN_ATU, ZZ0_EN_NEW, ZZ0_DATHOR,'SC1', SC1.R_E_C_N_O_, '" + DTOS(DATE()) + "', '" + SUBSTR(TIME(),1,5) + "', '" + __CUSERID + "' " + CRLF +;
		"FROM "+RetSqlName("SC1")+ " SC1 WITH (NOLOCK),"+RetSqlName("ZZ0")+ " ZZ0 WITH (NOLOCK) " + CRLF +;
		"WHERE SC1.D_E_L_E_T_ = ' ' " + CRLF +;
		"AND ZZ0.D_E_L_E_T_ = ' ' " + CRLF +;
		"AND SUBSTRING(C1_FILIAL,1,4) = '"+SubString(xFilial("SC1"),1,4)+"' " + CRLF +;
		"AND C1_RESIDUO <> 'S' " + CRLF +;
		"AND C1_QUANT > C1_QUJE " + CRLF +;
		"AND YEAR(C1_EMISSAO) >= "+ALLTRIM(STR(VAL(MV_PAR01) - 1))+" " + CRLF +;
		"AND C1_FLAGGCT <> '1' " + CRLF +;
		"AND ZZ0_EXERC = '"+MV_PAR01+"' " + CRLF +;
		"AND ZZ0_ENTID = '"+MV_PAR05+"' " + CRLF +;
		"AND ZZ0_PROCES = '1' " + CRLF +;
		"AND SUBSTRING(ZZ0_FILIAL,1,4) = SUBSTRING(C1_FILIAL,1,4) "
		DO CASE
		  	CASE MV_PAR05 == "1"
		  		cQuery += CRLF + "AND C1_CONTA = ZZ0_EN_ATU "
		  	CASE MV_PAR05 == "2"
		  		cQuery += CRLF + "AND C1_CC = ZZ0_EN_ATU "
		  	CASE MV_PAR05 == "3"
		  		cQuery += CRLF + "AND C1_ITEMCTA = ZZ0_EN_ATU "
		  	CASE MV_PAR05 == "4"
		  		cQuery += CRLF + "AND C1_CLVL = ZZ0_EN_ATU "
		ENDCASE
		IF !EMPTY(MV_PAR02)
			cQuery += CRLF + "AND C1_CC = '"+MV_PAR02+"' "
	    ENDIF
		IF !EMPTY(MV_PAR03)
			cQuery += CRLF + "AND C1_ITEMCTA = '"+MV_PAR03+"' "
	    ENDIF
		IF !EMPTY(MV_PAR04)
			cQuery += CRLF + "AND C1_CONTA = '"+MV_PAR04+"' "
	    ENDIF
		FWrite(nHdl,cQuery + CHR(13)+CHR(10))
		FWrite(nHdl," " + CHR(13)+CHR(10) )
		TcSqlExec(cQuery)
		
		cQuery := +;
		"UPDATE "+RetSqlName("SC1")+" " 
		DO CASE
		  	CASE MV_PAR05 == "1"
		  		cQuery += CRLF + "SET C1_CONTA = ZZ0_EN_NEW "
		  	CASE MV_PAR05 == "2"
		  		cQuery += CRLF + "SET C1_CC = ZZ0_EN_NEW "
		  	CASE MV_PAR05 == "3"
		  		cQuery += CRLF + "SET C1_ITEMCTA = ZZ0_EN_NEW "
		  	CASE MV_PAR05 == "4"
		  		cQuery += CRLF + "SET C1_CLVL = ZZ0_EN_NEW "
		ENDCASE
		cQuery += CRLF +;
		"FROM "+RetSqlName("SC1")+ " SC1 WITH (NOLOCK),"+RetSqlName("ZZ0")+ " ZZ0 WITH (NOLOCK) " + CRLF +;
		"WHERE SC1.D_E_L_E_T_ = ' ' " + CRLF +;
		"AND ZZ0.D_E_L_E_T_ = ' ' " + CRLF +;
		"AND SUBSTRING(C1_FILIAL,1,4) = '"+SubString(xFilial("SC1"),1,4)+"' " + CRLF +;
		"AND C1_RESIDUO <> 'S' " + CRLF +;
		"AND C1_QUANT > C1_QUJE " + CRLF +;
		"AND C1_FLAGGCT <> '1' " + CRLF +;
		"AND YEAR(C1_EMISSAO) >= "+ALLTRIM(STR(VAL(MV_PAR01) - 1))+" " + CRLF +;
		"AND ZZ0_EXERC = '"+MV_PAR01+"' " + CRLF +;
		"AND ZZ0_ENTID = '"+MV_PAR05+"' " + CRLF +;
		"AND ZZ0_PROCES = '1' " + CRLF +;
		"AND SUBSTRING(ZZ0_FILIAL,1,4) = SUBSTRING(C1_FILIAL,1,4) "
		DO CASE
		  	CASE MV_PAR05 == "1"
		  		cQuery += CRLF + "AND C1_CONTA = ZZ0_EN_ATU "
		  	CASE MV_PAR05 == "2"
		  		cQuery += CRLF + "AND C1_CC = ZZ0_EN_ATU "
		  	CASE MV_PAR05 == "3"
		  		cQuery += CRLF + "AND C1_ITEMCTA = ZZ0_EN_ATU "
		  	CASE MV_PAR05 == "4"
		  		cQuery += CRLF + "AND C1_CLVL = ZZ0_EN_ATU "
		ENDCASE
		IF !EMPTY(MV_PAR02)
			cQuery += CRLF + "AND C1_CC = '"+MV_PAR02+"' "
	    ENDIF
		IF !EMPTY(MV_PAR03)
			cQuery += CRLF + "AND C1_ITEMCTA = '"+MV_PAR03+"' "
	    ENDIF
		IF !EMPTY(MV_PAR04)
			cQuery += CRLF + "AND C1_CONTA = '"+MV_PAR04+"' "
	    ENDIF
		FWrite(nHdl,cQuery + CHR(13)+CHR(10))	
		FWrite(nHdl," " + CHR(13)+CHR(10) )
		TcSqlExec(cQuery)
	ELSE
		DbCloseArea()	
	ENDIF	
ENDIF	   


//ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
//บ Pedido de Compra                                                 บ
//ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
IF MV_PAR07 == 1
	cQuery := +;
	"SELECT C7_FILIAL, C7_ITEM, C7_NUM, C7_EMISSAO, C7_CONTA, C7_CC, C7_ITEMCTA, C7_CLVL, ZZ0_ENTID, ZZ0_EN_ATU, ZZ0_EN_NEW, SC7.R_E_C_N_O_ " + CRLF +;
	"FROM "+RetSqlName("SC7")+ " SC7 WITH (NOLOCK),"+RetSqlName("ZZ0")+ " ZZ0 WITH (NOLOCK) " + CRLF +;
	"WHERE SC7.D_E_L_E_T_ = ' ' " + CRLF +;
	"AND ZZ0.D_E_L_E_T_ = ' ' " + CRLF +;
	"AND SUBSTRING(C7_FILIAL,1,4) = '"+SubString(xFilial("SC7"),1,4)+"' " + CRLF +;
	"AND C7_RESIDUO <> 'S' " + CRLF +;
	"AND C7_QUANT > C7_QUJE " + CRLF +;
	"AND YEAR(C7_EMISSAO) >= "+ALLTRIM(STR(VAL(MV_PAR01) - 1))+" " + CRLF +;
	"AND ZZ0_EXERC = '"+MV_PAR01+"' " + CRLF +;
	"AND ZZ0_ENTID = '"+MV_PAR05+"' " + CRLF +;
	"AND ZZ0_PROCES = '1' " + CRLF +;
	"AND SUBSTRING(ZZ0_FILIAL,1,4) = SUBSTRING(C7_FILIAL,1,4) "
	DO CASE
	  	CASE MV_PAR05 == "1"
	  		cQuery += CRLF + "AND C7_CONTA = ZZ0_EN_ATU "
	  	CASE MV_PAR05 == "2"
	  		cQuery += CRLF + "AND C7_CC = ZZ0_EN_ATU "
	  	CASE MV_PAR05 == "3"
	  		cQuery += CRLF + "AND C7_ITEMCTA = ZZ0_EN_ATU "
	  	CASE MV_PAR05 == "4"
	  		cQuery += CRLF + "AND C7_CLVL = ZZ0_EN_ATU "
	ENDCASE
	IF !EMPTY(MV_PAR02)
		cQuery += CRLF + "AND C7_CC = '"+MV_PAR02+"' "
    ENDIF
	IF !EMPTY(MV_PAR03)
		cQuery += CRLF + "AND C7_ITEMCTA = '"+MV_PAR03+"' "
    ENDIF
	IF !EMPTY(MV_PAR04)
		cQuery += CRLF + "AND C7_CONTA = '"+MV_PAR04+"' "
    ENDIF
	
	cQuery += CRLF + "ORDER BY C7_FILIAL "
	DbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), "QRY", .T., .T.)
	Count to nCount
	TcSetField("QRY", "C7_EMISSAO", "D", 08, 0)

	_MSG += ALLTRIM(STR(nCount)) + ' registro(s) de pedido de compra' + CRLF
	
	FWrite(nHdl,"=========================================================================================================================================================================" + CHR(13)+CHR(10) )
	FWrite(nHdl,cQuery + CHR(13)+CHR(10))
	FWrite(nHdl," " + CHR(13)+CHR(10) )
	
	IF nCount > 0
		DbSelectArea("QRY")
		DbGoTop()
		While !Eof()
			cEntid := ""
		    If ZZ0_ENTID == '1'
		    	cEntid := "Conta Contabil"
				FWrite(nHdl,"PEDIDOS DE COMPRAS | "+C7_FILIAL+" | "+C7_NUM+" "+C7_ITEM+" | "+Dtoc(C7_EMISSAO)+" | "+cEntid+" | "+C7_CONTA+" | "+ZZ0_EN_NEW+" | "+ALLTRIM(STR(R_E_C_N_O_)) + CHR(13)+CHR(10) )
		    Elseif ZZ0_ENTID == '2'
		    	cEntid := "Centro de Custo"
				FWrite(nHdl,"PEDIDOS DE COMPRAS | "+C7_FILIAL+" | "+C7_NUM+" "+C7_ITEM+" | "+Dtoc(C7_EMISSAO)+" | "+cEntid+" | "+C7_CC+" | "+ZZ0_EN_NEW+" | "+ALLTRIM(STR(R_E_C_N_O_)) + CHR(13)+CHR(10) )
		    Elseif ZZ0_ENTID == '3'
		    	cEntid := "Item Contabil"
				FWrite(nHdl,"PEDIDOS DE COMPRAS | "+C7_FILIAL+" | "+C7_NUM+" "+C7_ITEM+" | "+Dtoc(C7_EMISSAO)+" | "+cEntid+" | "+C7_ITEMCTA+" | "+ZZ0_EN_NEW+" | "+ALLTRIM(STR(R_E_C_N_O_)) + CHR(13)+CHR(10) )
		    Elseif ZZ0_ENTID == '4'
		    	cEntid := "Classe de Valor"
				FWrite(nHdl,"PEDIDOS DE COMPRAS | "+C7_FILIAL+" | "+C7_NUM+" "+C7_ITEM+" | "+Dtoc(C7_EMISSAO)+" | "+cEntid+" | "+C7_CLVL+" | "+ZZ0_EN_NEW+" | "+ALLTRIM(STR(R_E_C_N_O_)) + CHR(13)+CHR(10) )
			Endif
			DbSkip()
		End	
		FWrite(nHdl,"" + CHR(13)+CHR(10) )
		DbCloseArea()		
		
		cQuery := +;
		"INSERT INTO ZZ1010(ZZ1_FILIAL,ZZ1_EXERC,ZZ1_ENTID,ZZ1_EN_ATU,ZZ1_EN_NEW,ZZ1_DATHOR,ZZ1_TABELA,ZZ1_RECNO,ZZ1_DATA,ZZ1_HORA,ZZ1_USERGI) " + CRLF +;
		"SELECT ZZ0_FILIAL, ZZ0_EXERC, ZZ0_ENTID, ZZ0_EN_ATU, ZZ0_EN_NEW, ZZ0_DATHOR,'SC7', SC7.R_E_C_N_O_, '" + DTOS(DATE()) + "', '" + SUBSTR(TIME(),1,5) + "', '" + __CUSERID + "' " + CRLF +;
		"FROM "+RetSqlName("SC7")+ " SC7 WITH (NOLOCK),"+RetSqlName("ZZ0")+ " ZZ0 WITH (NOLOCK) " + CRLF +;
		"WHERE SC7.D_E_L_E_T_ = ' ' " + CRLF +;
		"AND ZZ0.D_E_L_E_T_ = ' ' " + CRLF +;
		"AND SUBSTRING(C7_FILIAL,1,4) = '"+SubString(xFilial("SC7"),1,4)+"' " + CRLF +;
		"AND C7_RESIDUO <> 'S' " + CRLF +;
		"AND C7_QUANT > C7_QUJE " + CRLF +;
		"AND YEAR(C7_EMISSAO) >= "+ALLTRIM(STR(VAL(MV_PAR01) - 1))+" " + CRLF +;
		"AND ZZ0_EXERC = '"+MV_PAR01+"' " + CRLF +;
		"AND ZZ0_ENTID = '"+MV_PAR05+"' " + CRLF +;
		"AND ZZ0_PROCES = '1' " + CRLF +;
		"AND SUBSTRING(ZZ0_FILIAL,1,4) = SUBSTRING(C7_FILIAL,1,4) " 
		DO CASE
		  	CASE MV_PAR05 == "1"
		  		cQuery += CRLF + "AND C7_CONTA = ZZ0_EN_ATU "
		  	CASE MV_PAR05 == "2"
		  		cQuery += CRLF + "AND C7_CC = ZZ0_EN_ATU "
		  	CASE MV_PAR05 == "3"
		  		cQuery += CRLF + "AND C7_ITEMCTA = ZZ0_EN_ATU "
		  	CASE MV_PAR05 == "4"
		  		cQuery += CRLF + "AND C7_CLVL = ZZ0_EN_ATU "
		ENDCASE
		IF !EMPTY(MV_PAR02)
			cQuery += CRLF + "AND C7_CC = '"+MV_PAR02+"' "
	    ENDIF
		IF !EMPTY(MV_PAR03)
			cQuery += CRLF + "AND C7_ITEMCTA = '"+MV_PAR03+"' "
	    ENDIF
		IF !EMPTY(MV_PAR04)
			cQuery += CRLF + "AND C7_CONTA = '"+MV_PAR04+"' "
	    ENDIF
		FWrite(nHdl,cQuery + CHR(13)+CHR(10))
		FWrite(nHdl," " + CHR(13)+CHR(10) )
		TcSqlExec(cQuery)
		
		cQuery := +;
		"UPDATE "+RetSqlName("SC7")+" "
		DO CASE
		  	CASE MV_PAR05 == "1"
		  		cQuery += CRLF + "SET C7_CONTA = ZZ0_EN_NEW "
		  	CASE MV_PAR05 == "2"
		  		cQuery += CRLF + "SET C7_CC = ZZ0_EN_NEW "
		  	CASE MV_PAR05 == "3"
		  		cQuery += CRLF + "SET C7_ITEMCTA = ZZ0_EN_NEW "
		  	CASE MV_PAR05 == "4"
		  		cQuery += CRLF + "SET C7_CLVL = ZZ0_EN_NEW "
		ENDCASE       
		cQuery += CRLF +;
		"FROM "+RetSqlName("SC7")+ " SC7 WITH (NOLOCK),"+RetSqlName("ZZ0")+ " ZZ0 WITH (NOLOCK) " + CRLF +;
		"WHERE SC7.D_E_L_E_T_ = ' ' " + CRLF +;
		"AND ZZ0.D_E_L_E_T_ = ' ' " + CRLF +;
		"AND SUBSTRING(C7_FILIAL,1,4) = '"+SubString(xFilial("SC7"),1,4)+"' " + CRLF +;
		"AND C7_RESIDUO <> 'S' " + CRLF +;
		"AND C7_QUANT > C7_QUJE " + CRLF +;
		"AND YEAR(C7_EMISSAO) >= "+ALLTRIM(STR(VAL(MV_PAR01) - 1))+" " + CRLF +;
		"AND ZZ0_EXERC = '"+MV_PAR01+"' " + CRLF +;
		"AND ZZ0_ENTID = '"+MV_PAR05+"' " + CRLF +;
		"AND ZZ0_PROCES = '1' " + CRLF +;
		"AND SUBSTRING(ZZ0_FILIAL,1,4) = SUBSTRING(C7_FILIAL,1,4) "
		DO CASE
		  	CASE MV_PAR05 == "1"
		  		cQuery += CRLF + "AND C7_CONTA = ZZ0_EN_ATU "
		  	CASE MV_PAR05 == "2"
		  		cQuery += CRLF + "AND C7_CC = ZZ0_EN_ATU "
		  	CASE MV_PAR05 == "3"
		  		cQuery += CRLF + "AND C7_ITEMCTA = ZZ0_EN_ATU "
		  	CASE MV_PAR05 == "4"
		  		cQuery += CRLF + "AND C7_CLVL = ZZ0_EN_ATU "
		ENDCASE
		IF !EMPTY(MV_PAR02)
			cQuery += CRLF + "AND C7_CC = '"+MV_PAR02+"' "
	    ENDIF
		IF !EMPTY(MV_PAR03)
			cQuery += CRLF + "AND C7_ITEMCTA = '"+MV_PAR03+"' "
	    ENDIF
		IF !EMPTY(MV_PAR04)
			cQuery += CRLF + "AND C7_CONTA = '"+MV_PAR04+"' "
	    ENDIF
		FWrite(nHdl,cQuery + CHR(13)+CHR(10))	
		FWrite(nHdl," " + CHR(13)+CHR(10) )
		TcSqlExec(cQuery)
	ELSE
		DbCloseArea()
	ENDIF	
ENDIF	   


//ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
//บ Pr้-notas de Entrada                                             บ
//ศอออออออออออออออออออDออออออออออออออออออออออออออออออออออออออออออออออผ
IF MV_PAR08 == 1
	cQuery := +;
	"SELECT D1_FILIAL, D1_ITEM, D1_DOC, D1_EMISSAO, D1_CONTA, D1_CC, D1_ITEMCTA, D1_CLVL, ZZ0_ENTID, ZZ0_EN_ATU, ZZ0_EN_NEW, SD1.R_E_C_N_O_ " + CRLF +;
	"FROM "+RetSqlName("SD1")+ " SD1 WITH (NOLOCK),"+RetSqlName("ZZ0")+ " ZZ0 WITH (NOLOCK) " + CRLF +;
	"WHERE SD1.D_E_L_E_T_ = ' ' " + CRLF +;
	"AND ZZ0.D_E_L_E_T_ = ' ' " + CRLF +; 
	"AND SUBSTRING(D1_FILIAL,1,4) = '"+SubString(xFilial("SD1"),1,4)+"' " + CRLF +;
	"AND D1_TES = ' ' " + CRLF +;
	"AND YEAR(D1_EMISSAO) >= "+ALLTRIM(STR(VAL(MV_PAR01) - 1))+" " + CRLF +;
	"AND ZZ0_EXERC = '"+MV_PAR01+"' " + CRLF +;
	"AND ZZ0_ENTID = '"+MV_PAR05+"' " + CRLF +;
	"AND ZZ0_PROCES = '1' " + CRLF +;
	"AND SUBSTRING(ZZ0_FILIAL,1,4) = SUBSTRING(D1_FILIAL,1,4) " 
	DO CASE
	  	CASE MV_PAR05 == "1"
	  		cQuery += CRLF + "AND D1_CONTA = ZZ0_EN_ATU "
	  	CASE MV_PAR05 == "2"
	  		cQuery += CRLF + "AND D1_CC = ZZ0_EN_ATU "
	  	CASE MV_PAR05 == "3"
	  		cQuery += CRLF + "AND D1_ITEMCTA = ZZ0_EN_ATU "
	  	CASE MV_PAR05 == "4"
	  		cQuery += CRLF + "AND D1_CLVL = ZZ0_EN_ATU "
	ENDCASE
	IF !EMPTY(MV_PAR02)
		cQuery += CRLF + "AND D1_CC = '"+MV_PAR02+"' "
    ENDIF
	IF !EMPTY(MV_PAR03)
		cQuery += CRLF + "AND D1_ITEMCTA = '"+MV_PAR03+"' "
    ENDIF
	IF !EMPTY(MV_PAR04)
		cQuery += CRLF + "AND D1_CONTA = '"+MV_PAR04+"' "
    ENDIF
	cQuery += CRLF + "ORDER BY D1_FILIAL "
	DbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), "QRY", .T., .T.)
	Count to nCount
	TcSetField("QRY", "D1_EMISSAO", "D", 08, 0)

	_MSG += ALLTRIM(STR(nCount)) + ' registro(s) de pr้-nota de entrada' + CRLF

	FWrite(nHdl,"=========================================================================================================================================================================" + CHR(13)+CHR(10) )
	FWrite(nHdl,cQuery + CHR(13)+CHR(10))
	FWrite(nHdl," " + CHR(13)+CHR(10) )

	IF nCount > 0	
		DbSelectArea("QRY")
		DbGoTop()
		While !Eof()
			cEntid := ""
		    If ZZ0_ENTID == '1'
		    	cEntid := "Conta Contabil"
				FWrite(nHdl,"PRษ-NOTA DE ENTRADA | "+D1_FILIAL+" | "+D1_DOC+" "+D1_ITEM+" | "+Dtoc(D1_EMISSAO)+" | "+cEntid+" | "+D1_CONTA+" | "+ZZ0_EN_NEW+" | "+ALLTRIM(STR(R_E_C_N_O_)) + CHR(13)+CHR(10) )
		    Elseif ZZ0_ENTID == '2'
		    	cEntid := "Centro de Custo"
				FWrite(nHdl,"PRษ-NOTA DE ENTRADA | "+D1_FILIAL+" | "+D1_DOC+" "+D1_ITEM+" | "+Dtoc(D1_EMISSAO)+" | "+cEntid+" | "+D1_CC+" | "+ZZ0_EN_NEW+" | "+ALLTRIM(STR(R_E_C_N_O_)) + CHR(13)+CHR(10) )
		    Elseif ZZ0_ENTID == '3'
		    	cEntid := "Item Contabil"
				FWrite(nHdl,"PRษ-NOTA DE ENTRADA | "+D1_FILIAL+" | "+D1_DOC+" "+D1_ITEM+" | "+Dtoc(D1_EMISSAO)+" | "+cEntid+" | "+D1_ITEMCTA+" | "+ZZ0_EN_NEW+" | "+ALLTRIM(STR(R_E_C_N_O_)) + CHR(13)+CHR(10) )
		    Elseif ZZ0_ENTID == '4'
		    	cEntid := "Classe de Valor"
				FWrite(nHdl,"PRษ-NOTA DE ENTRADA | "+D1_FILIAL+" | "+D1_DOC+" "+D1_ITEM+" | "+Dtoc(D1_EMISSAO)+" | "+cEntid+" | "+D1_CLVL+" | "+ZZ0_EN_NEW+" | "+ALLTRIM(STR(R_E_C_N_O_)) + CHR(13)+CHR(10) )
			Endif
			DbSkip()
		End	
		FWrite(nHdl,"" + CHR(13)+CHR(10) )
		DbCloseArea()		
		
		cQuery := +;
		"INSERT INTO ZZ1010(ZZ1_FILIAL,ZZ1_EXERC,ZZ1_ENTID,ZZ1_EN_ATU,ZZ1_EN_NEW,ZZ1_DATHOR,ZZ1_TABELA,ZZ1_RECNO,ZZ1_DATA,ZZ1_HORA,ZZ1_USERGI) " + CRLF +;
		"SELECT ZZ0_FILIAL, ZZ0_EXERC, ZZ0_ENTID, ZZ0_EN_ATU, ZZ0_EN_NEW, ZZ0_DATHOR,'SD1', SD1.R_E_C_N_O_, '" + DTOS(DATE()) + "', '" + SUBSTR(TIME(),1,5) + "', '" + __CUSERID + "' " + CRLF +;
		"FROM "+RetSqlName("SD1")+ " SD1 WITH (NOLOCK),"+RetSqlName("ZZ0")+ " ZZ0 WITH (NOLOCK) " + CRLF +;
		"WHERE SD1.D_E_L_E_T_ = ' ' " + CRLF +;
		"AND ZZ0.D_E_L_E_T_ = ' ' " + CRLF +;
		"AND SUBSTRING(D1_FILIAL,1,4) = '"+SubString(xFilial("SD1"),1,4)+"' " + CRLF +;
		"AND D1_TES = ' ' " + CRLF +;
		"AND YEAR(D1_EMISSAO) >= "+ALLTRIM(STR(VAL(MV_PAR01) - 1))+" " + CRLF +;
		"AND ZZ0_EXERC = '"+MV_PAR01+"' " + CRLF +;
		"AND ZZ0_ENTID = '"+MV_PAR05+"' " + CRLF +;
		"AND ZZ0_PROCES = '1' " + CRLF +;
		"AND SUBSTRING(ZZ0_FILIAL,1,4) = SUBSTRING(D1_FILIAL,1,4) "
		DO CASE
		  	CASE MV_PAR05 == "1"
		  		cQuery += CRLF + "AND D1_CONTA = ZZ0_EN_ATU "
		  	CASE MV_PAR05 == "2"
		  		cQuery += CRLF + "AND D1_CC = ZZ0_EN_ATU "
		  	CASE MV_PAR05 == "3"
		  		cQuery += CRLF + "AND D1_ITEMCTA = ZZ0_EN_ATU "
		  	CASE MV_PAR05 == "4"
		  		cQuery += CRLF + "AND D1_CLVL = ZZ0_EN_ATU "
		ENDCASE
		IF !EMPTY(MV_PAR02)
			cQuery += CRLF + "AND D1_CC = '"+MV_PAR02+"' "
	    ENDIF
		IF !EMPTY(MV_PAR03)
			cQuery += CRLF + "AND D1_ITEMCTA = '"+MV_PAR03+"' "
	    ENDIF
		IF !EMPTY(MV_PAR04)
			cQuery += CRLF + "AND D1_CONTA = '"+MV_PAR04+"' "
	    ENDIF
		FWrite(nHdl,cQuery + CHR(13)+CHR(10))
		FWrite(nHdl," " + CHR(13)+CHR(10) )
		TcSqlExec(cQuery)
		
		cQuery := +;
		"UPDATE "+RetSqlName("SD1")+" " 
		DO CASE
		  	CASE MV_PAR05 == "1"
		  		cQuery += CRLF + "SET D1_CONTA = ZZ0_EN_NEW "
		  	CASE MV_PAR05 == "2"
		  		cQuery += CRLF + "SET D1_CC = ZZ0_EN_NEW "
		  	CASE MV_PAR05 == "3"
		  		cQuery += CRLF + "SET D1_ITEMCTA = ZZ0_EN_NEW "
		  	CASE MV_PAR05 == "4"
		  		cQuery += CRLF + "SET D1_CLVL = ZZ0_EN_NEW "
		ENDCASE
		cQuery += CRLF +;
		"FROM "+RetSqlName("SD1")+ " SD1 WITH (NOLOCK),"+RetSqlName("ZZ0")+ " ZZ0 WITH (NOLOCK) " + CRLF +;
		"WHERE SD1.D_E_L_E_T_ = ' ' " + CRLF +;
		"AND ZZ0.D_E_L_E_T_ = ' ' " + CRLF +; 
		"AND SUBSTRING(D1_FILIAL,1,4) = '"+SubString(xFilial("SD1"),1,4)+"' " + CRLF +;
		"AND D1_TES = ' ' " + CRLF +;
		"AND YEAR(D1_EMISSAO) >= "+ALLTRIM(STR(VAL(MV_PAR01) - 1))+" " + CRLF +;
		"AND ZZ0_EXERC = '"+MV_PAR01+"' " + CRLF +;
		"AND ZZ0_ENTID = '"+MV_PAR05+"' " + CRLF +;
		"AND ZZ0_PROCES = '1' " + CRLF +;
		"AND SUBSTRING(ZZ0_FILIAL,1,4) = SUBSTRING(D1_FILIAL,1,4) "
		DO CASE
		  	CASE MV_PAR05 == "1"
		  		cQuery += CRLF + "AND D1_CONTA = ZZ0_EN_ATU "
		  	CASE MV_PAR05 == "2"
		  		cQuery += CRLF + "AND D1_CC = ZZ0_EN_ATU "
		  	CASE MV_PAR05 == "3"
		  		cQuery += CRLF + "AND D1_ITEMCTA = ZZ0_EN_ATU "
		  	CASE MV_PAR05 == "4"
		  		cQuery += CRLF + "AND D1_CLVL = ZZ0_EN_ATU "
		ENDCASE
		IF !EMPTY(MV_PAR02)
			cQuery += CRLF + "AND D1_CC = '"+MV_PAR02+"' "
	    ENDIF
		IF !EMPTY(MV_PAR03)
			cQuery += CRLF + "AND D1_ITEMCTA = '"+MV_PAR03+"' "
	    ENDIF
		IF !EMPTY(MV_PAR04)
			cQuery += CRLF + "AND D1_CONTA = '"+MV_PAR04+"' "
	    ENDIF	
		FWrite(nHdl,cQuery + CHR(13)+CHR(10))
		FWrite(nHdl," " + CHR(13)+CHR(10) )
		TcSqlExec(cQuery) 
	ELSE
		DbCloseArea()				
	ENDIF	
ENDIF	


//ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
//บ Contratos                                                        บ
//ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
IF MV_PAR09 == 1
	cQuery := +;
	"SELECT CNB_FILIAL, CNB_CONTRA, CNB_REVISA, CNB_ITEM, CN9_DTINIC, CN9_DTFIM, CNB_CONTA, CNB_CC, CNB_ITEMCT, CNB_CLVL, ZZ0_ENTID, ZZ0_EN_ATU, ZZ0_EN_NEW, CNB.R_E_C_N_O_ " + CRLF +;
	"FROM "+RetSqlName("CNB")+ " CNB WITH (NOLOCK),"+RetSqlName("CN9")+ " CN9 WITH (NOLOCK), "+RetSqlName("ZZ0")+ " ZZ0 WITH (NOLOCK) " + CRLF +;
	"WHERE CNB.D_E_L_E_T_ = ' ' " + CRLF +;
	"AND CN9.D_E_L_E_T_ = ' ' " + CRLF +; 
	"AND ZZ0.D_E_L_E_T_ = ' ' " + CRLF +; 
	"AND SUBSTRING(CNB_FILIAL,1,4) = '"+SubString(xFilial("CNB"),1,4)+"' " + CRLF +;
	"AND CN9_FILIAL = CNB_FILIAL " + CRLF +;
	"AND CN9_NUMERO = CNB_CONTRA " + CRLF +;
	"AND CN9_REVISA = CNB_REVISA " + CRLF +;
	"AND CN9_SITUAC = '05' " + CRLF +;
	"AND ZZ0_EXERC = '"+MV_PAR01+"' " + CRLF +;
	"AND ZZ0_ENTID = '"+MV_PAR05+"' " + CRLF +;
	"AND ZZ0_PROCES = '1' " + CRLF +;
	"AND SUBSTRING(ZZ0_FILIAL,1,4) = SUBSTRING(CNB_FILIAL,1,4) " 
	DO CASE
	  	CASE MV_PAR05 == "1"
	  		cQuery += CRLF + "AND CNB_CONTA = ZZ0_EN_ATU "
	  	CASE MV_PAR05 == "2"
	  		cQuery += CRLF + "AND CNB_CC = ZZ0_EN_ATU "
	  	CASE MV_PAR05 == "3"
	  		cQuery += CRLF + "AND CNB_ITEMCT = ZZ0_EN_ATU "
	  	CASE MV_PAR05 == "4"
	  		cQuery += CRLF + "AND CNB_CLVL = ZZ0_EN_ATU "
	ENDCASE
	IF !EMPTY(MV_PAR02)
		cQuery += CRLF + "AND CNB_CC = '"+MV_PAR02+"' "
    ENDIF
	IF !EMPTY(MV_PAR03)
		cQuery += CRLF + "AND CNB_ITEMCT = '"+MV_PAR03+"' "
    ENDIF
	IF !EMPTY(MV_PAR04)
		cQuery += CRLF + "AND CNB_CONTA = '"+MV_PAR04+"' "
    ENDIF
	cQuery += CRLF + "ORDER BY CNB_FILIAL "
	DbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), "QRY", .T., .T.)
	Count to nCount
	TcSetField("QRY", "CN9_DTINIC", "D", 08, 0)
	TcSetField("QRY", "CN9_DTFIM", "D", 08, 0)

	_MSG += ALLTRIM(STR(nCount)) + ' registro(s) de contrato' + CRLF

	FWrite(nHdl,"=========================================================================================================================================================================" + CHR(13)+CHR(10) )
	FWrite(nHdl,cQuery + CHR(13)+CHR(10))
	FWrite(nHdl," " + CHR(13)+CHR(10) )

	IF nCount > 0	
		DbSelectArea("QRY")
		DbGoTop()
		While !Eof()
			cEntid := ""                                                                  
			
			_AUX += IIF(EMPTY(_AUX),ALLTRIM(STR(R_E_C_N_O_)),','+ALLTRIM(STR(R_E_C_N_O_)))
			
		    If ZZ0_ENTID == '1'
		    	cEntid := "Conta Contabil"
				FWrite(nHdl,"CONTRATOS VIGENTES | "+CNB_FILIAL+" | "+CNB_CONTRA+" | "+CNB_REVISA+" | "+CNB_ITEM+" | "+Dtoc(CN9_DTINIC)+" | "+Dtoc(CN9_DTFIM)+" | "+cEntid+" | "+CNB_CONTA+" | "+ZZ0_EN_NEW+" | "+ALLTRIM(STR(R_E_C_N_O_)) + CHR(13)+CHR(10) )
		    Elseif ZZ0_ENTID == '2'
		    	cEntid := "Centro de Custo"
				FWrite(nHdl,"CONTRATOS VIGENTES | "+CNB_FILIAL+" | "+CNB_CONTRA+" | "+CNB_REVISA+" | "+CNB_ITEM+" | "+Dtoc(CN9_DTINIC)+" | "+Dtoc(CN9_DTFIM)+" | "+cEntid+" | "+CNB_CC+" | "+ZZ0_EN_NEW+" | "+ALLTRIM(STR(R_E_C_N_O_)) + CHR(13)+CHR(10) )
		    Elseif ZZ0_ENTID == '3'
		    	cEntid := "Item Contabil"
				FWrite(nHdl,"CONTRATOS VIGENTES | "+CNB_FILIAL+" | "+CNB_CONTRA+" | "+CNB_REVISA+" | "+CNB_ITEM+" | "+Dtoc(CN9_DTINIC)+" | "+Dtoc(CN9_DTFIM)+" | "+cEntid+" | "+CNB_ITEMCT+" | "+ZZ0_EN_NEW+" | "+ALLTRIM(STR(R_E_C_N_O_)) + CHR(13)+CHR(10) )
		    Elseif ZZ0_ENTID == '4'
		    	cEntid := "Classe de Valor"
				FWrite(nHdl,"CONTRATOS VIGENTES | "+CNB_FILIAL+" | "+CNB_CONTRA+" | "+CNB_REVISA+" | "+CNB_ITEM+" | "+Dtoc(CN9_DTINIC)+" | "+Dtoc(CN9_DTFIM)+" | "+cEntid+" | "+CNB_CLVL+" | "+ZZ0_EN_NEW+" | "+ALLTRIM(STR(R_E_C_N_O_)) + CHR(13)+CHR(10) )
			Endif
			DbSkip()
		End	
		FWrite(nHdl,"" + CHR(13)+CHR(10) )
		DbCloseArea()		
		
		cQuery := +;
		"INSERT INTO ZZ1010(ZZ1_FILIAL,ZZ1_EXERC,ZZ1_ENTID,ZZ1_EN_ATU,ZZ1_EN_NEW,ZZ1_DATHOR,ZZ1_TABELA,ZZ1_RECNO,ZZ1_DATA,ZZ1_HORA,ZZ1_USERGI) " + CRLF +;	
		"SELECT ZZ0_FILIAL, ZZ0_EXERC, ZZ0_ENTID, ZZ0_EN_ATU, ZZ0_EN_NEW, ZZ0_DATHOR,'CNB', CNB.R_E_C_N_O_, '" + DTOS(DATE()) + "', '" + SUBSTR(TIME(),1,5) + "', '" + __CUSERID + "' " + CRLF +;	
		"FROM "+RetSqlName("CNB")+ " CNB WITH (NOLOCK),"+RetSqlName("CN9")+ " CN9 WITH (NOLOCK), "+RetSqlName("ZZ0")+ " ZZ0 WITH (NOLOCK) " + CRLF +;
		"WHERE CNB.D_E_L_E_T_ = ' ' " + CRLF +;
		"AND CN9.D_E_L_E_T_ = ' ' " + CRLF +;
		"AND ZZ0.D_E_L_E_T_ = ' ' " + CRLF +; 
		"AND SUBSTRING(CNB_FILIAL,1,4) = '"+SubString(xFilial("CNB"),1,4)+"' " + CRLF +;
		"AND CN9_FILIAL = CNB_FILIAL " + CRLF +;
		"AND CN9_NUMERO = CNB_CONTRA " + CRLF +;
		"AND CN9_REVISA = CNB_REVISA " + CRLF +;
		"AND CN9_SITUAC = '05' " + CRLF +;
		"AND ZZ0_EXERC = '"+MV_PAR01+"' " + CRLF +;
		"AND ZZ0_ENTID = '"+MV_PAR05+"' " + CRLF +;
		"AND ZZ0_PROCES = '1' " + CRLF +;
		"AND SUBSTRING(ZZ0_FILIAL,1,4) = SUBSTRING(CNB_FILIAL,1,4) " 
		DO CASE
		  	CASE MV_PAR05 == "1"
		  		cQuery += CRLF + "AND CNB_CONTA = ZZ0_EN_ATU "
		  	CASE MV_PAR05 == "2"
		  		cQuery += CRLF + "AND CNB_CC = ZZ0_EN_ATU "
		  	CASE MV_PAR05 == "3"
		  		cQuery += CRLF + "AND CNB_ITEMCT = ZZ0_EN_ATU "
		  	CASE MV_PAR05 == "4"
		  		cQuery += CRLF + "AND CNB_CLVL = ZZ0_EN_ATU "
		ENDCASE
		IF !EMPTY(MV_PAR02)
			cQuery += CRLF + "AND CNB_CC = '"+MV_PAR02+"' "
	    ENDIF
		IF !EMPTY(MV_PAR03)
			cQuery += CRLF + "AND CNB_ITEMCT = '"+MV_PAR03+"' "
	    ENDIF
		IF !EMPTY(MV_PAR04)
			cQuery += CRLF + "AND CMN_CONTA = '"+MV_PAR04+"' "
	    ENDIF	
		FWrite(nHdl,cQuery + CHR(13)+CHR(10))
		FWrite(nHdl," " + CHR(13)+CHR(10) )
		TcSqlExec(cQuery)
		
		cQuery := +;
		"UPDATE "+RetSqlName("CNB")+" " 
		DO CASE
		  	CASE MV_PAR05 == "1"
		  		cQuery += CRLF + "SET CNB_CONTA = ZZ0_EN_NEW "
		  	CASE MV_PAR05 == "2"
		  		cQuery += CRLF + "SET CNB_CC = ZZ0_EN_NEW "
		  	CASE MV_PAR05 == "3"
		  		cQuery += CRLF + "SET CNB_ITEMCT = ZZ0_EN_NEW "
		  	CASE MV_PAR05 == "4"
		  		cQuery += CRLF + "SET CNB_CLVL = ZZ0_EN_NEW "
		ENDCASE
		cQuery += CRLF +;
		"FROM "+RetSqlName("CNB")+ " CNB WITH (NOLOCK),"+RetSqlName("CN9")+ " CN9 WITH (NOLOCK), "+RetSqlName("ZZ0")+ " ZZ0 WITH (NOLOCK) " + CRLF +;
		"WHERE CNB.D_E_L_E_T_ = ' ' " + CRLF +;
		"AND CN9.D_E_L_E_T_ = ' ' " + CRLF +; 
		"AND ZZ0.D_E_L_E_T_ = ' ' " + CRLF +; 
		"AND SUBSTRING(CNB_FILIAL,1,4) = '"+SubString(xFilial("CNB"),1,4)+"' " + CRLF +;
		"AND CN9_FILIAL = CNB_FILIAL " + CRLF +;
		"AND CN9_NUMERO = CNB_CONTRA " + CRLF +;
		"AND CN9_REVISA = CNB_REVISA " + CRLF +;
		"AND CN9_SITUAC = '05' " + CRLF +;
		"AND ZZ0_EXERC = '"+MV_PAR01+"' " + CRLF +;
		"AND ZZ0_ENTID = '"+MV_PAR05+"' " + CRLF +;
		"AND ZZ0_PROCES = '1' " + CRLF +;
		"AND SUBSTRING(ZZ0_FILIAL,1,4) = SUBSTRING(CNB_FILIAL,1,4) " 
		DO CASE
		  	CASE MV_PAR05 == "1"
		  		cQuery += CRLF + "AND CNB_CONTA = ZZ0_EN_ATU "
		  	CASE MV_PAR05 == "2"
		  		cQuery += CRLF + "AND CNB_CC = ZZ0_EN_ATU "
		  	CASE MV_PAR05 == "3"
		  		cQuery += CRLF + "AND CNB_ITEMCT = ZZ0_EN_ATU "
		  	CASE MV_PAR05 == "4"
		  		cQuery += CRLF + "AND CNB_CLVL = ZZ0_EN_ATU "
		ENDCASE
		IF !EMPTY(MV_PAR02)
			cQuery += CRLF + "AND CNB_CC = '"+MV_PAR02+"' "
	    ENDIF
		IF !EMPTY(MV_PAR03)
			cQuery += CRLF + "AND CNB_ITEMCT = '"+MV_PAR03+"' "
	    ENDIF
		IF !EMPTY(MV_PAR04)
			cQuery += CRLF + "AND CNB_CONTA = '"+MV_PAR04+"' "
	    ENDIF	
		FWrite(nHdl,cQuery + CHR(13)+CHR(10))
		FWrite(nHdl," " + CHR(13)+CHR(10) )
		TcSqlExec(cQuery) 
	ELSE
		DbCloseArea()	
	ENDIF	

	//ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
	//บ Solicita็ใo de Compra de Contratos                               บ
	//ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
	IF !EMPTY(_AUX)
		cQuery := +;
		"SELECT C1_FILIAL, C1_ITEM, C1_NUM, C1_EMISSAO, C1_CONTA, C1_CC, C1_ITEMCTA, C1_CLVL, ZZ0_ENTID, ZZ0_EN_ATU, ZZ0_EN_NEW, SC1.R_E_C_N_O_ " + CRLF +;
		"FROM "+RetSqlName("SC1")+ " SC1 WITH (NOLOCK),"+RetSqlName("CNB")+ " CNB WITH (NOLOCK),"+RetSqlName("ZZ0")+ " ZZ0 WITH (NOLOCK) " + CRLF +;
		"WHERE SC1.D_E_L_E_T_ = ' ' " + CRLF +;
		"AND CNB.D_E_L_E_T_ = ' ' " + CRLF +;  
		"AND ZZ0.D_E_L_E_T_ = ' ' " + CRLF +;  
		"AND SUBSTRING(C1_FILIAL,1,4) = '"+SubString(xFilial("SC1"),1,4)+"' " + CRLF +;
		"AND CNB.R_E_C_N_O_ IN (" + _AUX + ") " + CRLF +;
		"AND C1_FILIAL = CASE WHEN CNB_FILORI <> '' THEN CNB_FILORI ELSE CNB_FILIAL END " + CRLF +;
		"AND C1_NUM = CNB_NUMSC " + CRLF +;
		"AND C1_ITEM = CNB_ITEMSC " + CRLF +;
		"AND C1_PRODUTO = CNB_PRODUT " + CRLF +;
		"AND ZZ0_EXERC = '"+MV_PAR01+"' " + CRLF +;
		"AND ZZ0_ENTID = '"+MV_PAR05+"' " + CRLF +;
		"AND ZZ0_PROCES = '1' " + CRLF +;
		"AND SUBSTRING(ZZ0_FILIAL,1,4) = SUBSTRING(C1_FILIAL,1,4) "
		DO CASE
		  	CASE MV_PAR05 == "1"
		  		cQuery += CRLF + "AND C1_CONTA = ZZ0_EN_ATU "
		  	CASE MV_PAR05 == "2"
		  		cQuery += CRLF + "AND C1_CC = ZZ0_EN_ATU "
		  	CASE MV_PAR05 == "3"
		  		cQuery += CRLF + "AND C1_ITEMCTA = ZZ0_EN_ATU "
		  	CASE MV_PAR05 == "4"
		  		cQuery += CRLF + "AND C1_CLVL = ZZ0_EN_ATU "
		ENDCASE
		IF !EMPTY(MV_PAR02)
			cQuery += CRLF + "AND C1_CC = '"+MV_PAR02+"' "
	    ENDIF
		IF !EMPTY(MV_PAR03)
			cQuery += CRLF + "AND C1_ITEMCTA = '"+MV_PAR03+"' "
	    ENDIF
		IF !EMPTY(MV_PAR04)
			cQuery += CRLF + "AND C1_CONTA = '"+MV_PAR04+"' "
	    ENDIF
	    
		cQuery += CRLF + "ORDER BY C1_FILIAL"
		DbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), "QRY", .T., .T.)
		Count to nCount
		TcSetField("QRY", "C1_EMISSAO", "D", 08, 0)
	
		_MSG += ALLTRIM(STR(nCount)) + ' registro(s) de solicita็ใo de compra de contrato' + CRLF
			
		FWrite(nHdl,"=========================================================================================================================================================================" + CHR(13)+CHR(10) )
		FWrite(nHdl,cQuery + CHR(13)+CHR(10))
		FWrite(nHdl," " + CHR(13)+CHR(10) )
		
		IF nCount > 0
			DbSelectArea("QRY")
			DbGoTop()
			While !Eof()
				cEntid := ""
			    If ZZ0_ENTID == '1'
			    	cEntid := "Conta Contabil"
					FWrite(nHdl,"SOLICITAวีES DE COMPRAS - CONTRATOS | "+C1_FILIAL+" | "+C1_NUM+" "+C1_ITEM+" | "+Dtoc(C1_EMISSAO)+" | "+cEntid+" | "+C1_CONTA+" | "+ZZ0_EN_NEW+" | "+ALLTRIM(STR(R_E_C_N_O_)) + CHR(13)+CHR(10) )
			    Elseif ZZ0_ENTID == '2'
			    	cEntid := "Centro de Custo"
					FWrite(nHdl,"SOLICITAวีES DE COMPRAS - CONTRATOS | "+C1_FILIAL+" | "+C1_NUM+" "+C1_ITEM+" | "+Dtoc(C1_EMISSAO)+" | "+cEntid+" | "+C1_CC+" | "+ZZ0_EN_NEW+" | "+ALLTRIM(STR(R_E_C_N_O_)) + CHR(13)+CHR(10) )
			    Elseif ZZ0_ENTID == '3'
			    	cEntid := "Item Contabil"
					FWrite(nHdl,"SOLICITAวีES DE COMPRAS - CONTRATOS | "+C1_FILIAL+" | "+C1_NUM+" "+C1_ITEM+" | "+Dtoc(C1_EMISSAO)+" | "+cEntid+" | "+C1_ITEMCTA+" | "+ZZ0_EN_NEW+" | "+ALLTRIM(STR(R_E_C_N_O_)) + CHR(13)+CHR(10) )
			    Elseif ZZ0_ENTID == '4'
			    	cEntid := "Classe de Valor"
					FWrite(nHdl,"SOLICITAวีES DE COMPRAS - CONTRATOS | "+C1_FILIAL+" | "+C1_NUM+" "+C1_ITEM+" | "+Dtoc(C1_EMISSAO)+" | "+cEntid+" | "+C1_CLVL+" | "+ZZ0_EN_NEW+" | "+ALLTRIM(STR(R_E_C_N_O_)) + CHR(13)+CHR(10) )
				Endif
				DbSkip()
			End	
			FWrite(nHdl,"" + CHR(13)+CHR(10) )
			DbCloseArea()		
			
			cQuery := +;
			"INSERT INTO ZZ1010(ZZ1_FILIAL,ZZ1_EXERC,ZZ1_ENTID,ZZ1_EN_ATU,ZZ1_EN_NEW,ZZ1_DATHOR,ZZ1_TABELA,ZZ1_RECNO,ZZ1_DATA,ZZ1_HORA,ZZ1_USERGI) " + CRLF +;
			"SELECT ZZ0_FILIAL, ZZ0_EXERC, ZZ0_ENTID, ZZ0_EN_ATU, ZZ0_EN_NEW, ZZ0_DATHOR,'SC1', SC1.R_E_C_N_O_, '" + DTOS(DATE()) + "', '" + SUBSTR(TIME(),1,5) + "', '" + __CUSERID + "' " + CRLF +;
			"FROM "+RetSqlName("SC1")+ " SC1 WITH (NOLOCK),"+RetSqlName("CNB")+ " CNB WITH (NOLOCK),"+RetSqlName("ZZ0")+ " ZZ0 WITH (NOLOCK) " + CRLF +;
			"WHERE SC1.D_E_L_E_T_ = ' ' " + CRLF +;
			"AND CNB.D_E_L_E_T_ = ' ' " + CRLF +;  
			"AND ZZ0.D_E_L_E_T_ = ' ' " + CRLF +;  
			"AND SUBSTRING(C1_FILIAL,1,4) = '"+SubString(xFilial("SC1"),1,4)+"' " + CRLF +;
			"AND CNB.R_E_C_N_O_ IN (" + _AUX + ") " + CRLF +;
			"AND C1_FILIAL = CASE WHEN CNB_FILORI <> '' THEN CNB_FILORI ELSE CNB_FILIAL END " + CRLF +;
			"AND C1_NUM = CNB_NUMSC " + CRLF +;
			"AND C1_ITEM = CNB_ITEMSC " + CRLF +;
			"AND C1_PRODUTO = CNB_PRODUT " + CRLF +;
			"AND ZZ0_EXERC = '"+MV_PAR01+"' " + CRLF +;
			"AND ZZ0_ENTID = '"+MV_PAR05+"' " + CRLF +;
			"AND ZZ0_PROCES = '1' " + CRLF +;
			"AND SUBSTRING(ZZ0_FILIAL,1,4) = SUBSTRING(C1_FILIAL,1,4) "
			DO CASE
			  	CASE MV_PAR05 == "1"
			  		cQuery += CRLF + "AND C1_CONTA = ZZ0_EN_ATU "
			  	CASE MV_PAR05 == "2"
			  		cQuery += CRLF + "AND C1_CC = ZZ0_EN_ATU "
			  	CASE MV_PAR05 == "3"
			  		cQuery += CRLF + "AND C1_ITEMCTA = ZZ0_EN_ATU "
			  	CASE MV_PAR05 == "4"
			  		cQuery += CRLF + "AND C1_CLVL = ZZ0_EN_ATU "
			ENDCASE
			IF !EMPTY(MV_PAR02)
				cQuery += CRLF + "AND C1_CC = '"+MV_PAR02+"' "
		    ENDIF
			IF !EMPTY(MV_PAR03)
				cQuery += CRLF + "AND C1_ITEMCTA = '"+MV_PAR03+"' "
		    ENDIF
			IF !EMPTY(MV_PAR04)
				cQuery += CRLF + "AND C1_CONTA = '"+MV_PAR04+"' "
		    ENDIF
			FWrite(nHdl,cQuery + CHR(13)+CHR(10))
			FWrite(nHdl," " + CHR(13)+CHR(10) )
			TcSqlExec(cQuery)
			
			cQuery := +;
			"UPDATE "+RetSqlName("SC1")+" " 
			DO CASE
			  	CASE MV_PAR05 == "1"
			  		cQuery += CRLF + "SET C1_CONTA = ZZ0_EN_NEW "
			  	CASE MV_PAR05 == "2"
			  		cQuery += CRLF + "SET C1_CC = ZZ0_EN_NEW "
			  	CASE MV_PAR05 == "3"
			  		cQuery += CRLF + "SET C1_ITEMCTA = ZZ0_EN_NEW "
			  	CASE MV_PAR05 == "4"
			  		cQuery += CRLF + "SET C1_CLVL = ZZ0_EN_NEW "
			ENDCASE
			cQuery += CRLF +;
			"FROM "+RetSqlName("SC1")+ " SC1 WITH (NOLOCK),"+RetSqlName("CNB")+ " CNB WITH (NOLOCK),"+RetSqlName("ZZ0")+ " ZZ0 WITH (NOLOCK) " + CRLF +;
			"WHERE SC1.D_E_L_E_T_ = ' ' " + CRLF +;
			"AND CNB.D_E_L_E_T_ = ' ' " + CRLF +;  
			"AND ZZ0.D_E_L_E_T_ = ' ' " + CRLF +;  
			"AND SUBSTRING(C1_FILIAL,1,4) = '"+SubString(xFilial("SC1"),1,4)+"' " + CRLF +;
			"AND CNB.R_E_C_N_O_ IN (" + _AUX + ") " + CRLF +;
			"AND C1_FILIAL = CASE WHEN CNB_FILORI <> '' THEN CNB_FILORI ELSE CNB_FILIAL END " + CRLF +;
			"AND C1_NUM = CNB_NUMSC " + CRLF +;
			"AND C1_ITEM = CNB_ITEMSC " + CRLF +;
			"AND C1_PRODUTO = CNB_PRODUT " + CRLF +;
			"AND ZZ0_EXERC = '"+MV_PAR01+"' " + CRLF +;
			"AND ZZ0_ENTID = '"+MV_PAR05+"' " + CRLF +;
			"AND ZZ0_PROCES = '1' " + CRLF +;
			"AND SUBSTRING(ZZ0_FILIAL,1,4) = SUBSTRING(C1_FILIAL,1,4) "
			DO CASE
			  	CASE MV_PAR05 == "1"
			  		cQuery += CRLF + "AND C1_CONTA = ZZ0_EN_ATU "
			  	CASE MV_PAR05 == "2"
			  		cQuery += CRLF + "AND C1_CC = ZZ0_EN_ATU "
			  	CASE MV_PAR05 == "3"
			  		cQuery += CRLF + "AND C1_ITEMCTA = ZZ0_EN_ATU "
			  	CASE MV_PAR05 == "4"
			  		cQuery += CRLF + "AND C1_CLVL = ZZ0_EN_ATU "
			ENDCASE
			IF !EMPTY(MV_PAR02)
				cQuery += CRLF + "AND C1_CC = '"+MV_PAR02+"' "
		    ENDIF
			IF !EMPTY(MV_PAR03)
				cQuery += CRLF + "AND C1_ITEMCTA = '"+MV_PAR03+"' "
		    ENDIF
			IF !EMPTY(MV_PAR04)
				cQuery += CRLF + "AND C1_CONTA = '"+MV_PAR04+"' "
		    ENDIF
			FWrite(nHdl,cQuery + CHR(13)+CHR(10))	
			FWrite(nHdl," " + CHR(13)+CHR(10) )
			TcSqlExec(cQuery)
		ELSE
			DbCloseArea()	
		ENDIF	
	ENDIF	   
ENDIF	   
	   

//ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
//บ Medi็๕es                                                         บ
//ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
IF MV_PAR10 == 1
	cQuery := +;
	"SELECT CNE_FILIAL, CNE_CONTRA, CNE_REVISA, CNE_NUMMED, CNE_ITEM, CN9_DTINIC, CN9_DTFIM, CNE_CONTA, CNE_CC, CNE_ITEMCT, CNE_CLVL, ZZ0_ENTID, ZZ0_EN_ATU, ZZ0_EN_NEW, CNE.R_E_C_N_O_ " + CRLF +;
	"FROM "+RetSqlName("CNE")+ " CNE WITH (NOLOCK),"+RetSqlName("CN9")+ " CN9 WITH (NOLOCK), "+RetSqlName("ZZ0")+ " ZZ0 WITH (NOLOCK) " + CRLF +;
	"WHERE CNE.D_E_L_E_T_ = ' ' " + CRLF +;
	"AND CN9.D_E_L_E_T_ = ' ' " + CRLF +;
	"AND ZZ0.D_E_L_E_T_ = ' ' " + CRLF +; 
	"AND SUBSTRING(CNE_FILIAL,1,4) = '"+SubString(xFilial("CNE"),1,4)+"' " + CRLF +;
	"AND CN9_FILIAL = CNE_FILIAL " + CRLF +;
	"AND CN9_NUMERO = CNE_CONTRA " + CRLF +;
	"AND CN9_REVISA = CNE_REVISA " + CRLF +;
	"AND CN9_SITUAC = '05' " + CRLF +;
	"AND ZZ0_EXERC = '"+MV_PAR01+"' " + CRLF +;
	"AND ZZ0_ENTID = '"+MV_PAR05+"' " + CRLF +;
	"AND ZZ0_PROCES = '1' " + CRLF +;
	"AND SUBSTRING(ZZ0_FILIAL,1,4) = SUBSTRING(CNE_FILIAL,1,4) " 
	DO CASE
	  	CASE MV_PAR05 == "1"
	  		cQuery += CRLF + "AND CNE_CONTA = ZZ0_EN_ATU "
	  	CASE MV_PAR05 == "2"
	  		cQuery += CRLF + "AND CNE_CC = ZZ0_EN_ATU "
	  	CASE MV_PAR05 == "3"
	  		cQuery += CRLF + "AND CNE_ITEMCT = ZZ0_EN_ATU "
	  	CASE MV_PAR05 == "4"
	  		cQuery += CRLF + "AND CNE_CLVL = ZZ0_EN_ATU "
	ENDCASE
	IF !EMPTY(MV_PAR02)
		cQuery += CRLF + "AND CNE_CC = '"+MV_PAR02+"' "
    ENDIF
	IF !EMPTY(MV_PAR03)
		cQuery += CRLF + "AND CNE_ITEMCT = '"+MV_PAR03+"' "
    ENDIF
	IF !EMPTY(MV_PAR04)
		cQuery += CRLF + "AND CNE_CONTA = '"+MV_PAR04+"' "
    ENDIF
	cQuery += CRLF + "ORDER BY CNE_FILIAL "
	DbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), "QRY", .T., .T.)
	Count to nCount
	TcSetField("QRY", "CN9_DTINIC", "D", 08, 0)
	TcSetField("QRY", "CN9_DTFIM", "D", 08, 0)

	_MSG += ALLTRIM(STR(nCount)) + ' registro(s) de medi็ใo de contrato' + CRLF

	FWrite(nHdl,"=========================================================================================================================================================================" + CHR(13)+CHR(10) )
	FWrite(nHdl,cQuery + CHR(13)+CHR(10))
	FWrite(nHdl," " + CHR(13)+CHR(10) )

	IF nCount > 0	
		DbSelectArea("QRY")
		DbGoTop()
		While !Eof()
			cEntid := ""
		    If ZZ0_ENTID == '1'
		    	cEntid := "Conta Contabil"
				FWrite(nHdl,"MEDIวรO DE CONTRATO | "+CNE_FILIAL+" | "+CNE_CONTRA+" | "+CNE_REVISA+" | "+CNE_NUMMED+" | "+CNE_ITEM+" | "+Dtoc(CN9_DTINIC)+" | "+Dtoc(CN9_DTFIM)+" | "+cEntid+" | "+CNE_CONTA+" | "+ZZ0_EN_NEW+" | "+ALLTRIM(STR(R_E_C_N_O_)) + CHR(13)+CHR(10) )
		    Elseif ZZ0_ENTID == '2'
		    	cEntid := "Centro de Custo"
				FWrite(nHdl,"MEDIวรO DE CONTRATO | "+CNE_FILIAL+" | "+CNE_CONTRA+" | "+CNE_REVISA+" | "+CNE_NUMMED+" | "+CNE_ITEM+" | "+Dtoc(CN9_DTINIC)+" | "+Dtoc(CN9_DTFIM)+" | "+cEntid+" | "+CNE_CC+" | "+ZZ0_EN_NEW+" | "+ALLTRIM(STR(R_E_C_N_O_)) + CHR(13)+CHR(10) )
		    Elseif ZZ0_ENTID == '3'
		    	cEntid := "Item Contabil"
				FWrite(nHdl,"MEDIวรO DE CONTRATO | "+CNE_FILIAL+" | "+CNE_CONTRA+" | "+CNE_REVISA+" | "+CNE_NUMMED+" | "+CNE_ITEM+" | "+Dtoc(CN9_DTINIC)+" | "+Dtoc(CN9_DTFIM)+" | "+cEntid+" | "+CNE_ITEMCT+" | "+ZZ0_EN_NEW+" | "+ALLTRIM(STR(R_E_C_N_O_)) + CHR(13)+CHR(10) )
		    Elseif ZZ0_ENTID == '4'
		    	cEntid := "Classe de Valor"
				FWrite(nHdl,"MEDIวรO DE CONTRATO | "+CNE_FILIAL+" | "+CNE_CONTRA+" | "+CNE_REVISA+" | "+CNE_NUMMED+" | "+CNE_ITEM+" | "+Dtoc(CN9_DTINIC)+" | "+Dtoc(CN9_DTFIM)+" | "+cEntid+" | "+CNE_CLVL+" | "+ZZ0_EN_NEW+" | "+ALLTRIM(STR(R_E_C_N_O_)) + CHR(13)+CHR(10) )
			Endif
			DbSkip()
		End	
		FWrite(nHdl,"" + CHR(13)+CHR(10) )
		DbCloseArea()		
		
		cQuery := +;
		"INSERT INTO ZZ1010(ZZ1_FILIAL,ZZ1_EXERC,ZZ1_ENTID,ZZ1_EN_ATU,ZZ1_EN_NEW,ZZ1_DATHOR,ZZ1_TABELA,ZZ1_RECNO,ZZ1_DATA,ZZ1_HORA,ZZ1_USERGI) " + CRLF +;	
		"SELECT ZZ0_FILIAL, ZZ0_EXERC, ZZ0_ENTID, ZZ0_EN_ATU, ZZ0_EN_NEW, ZZ0_DATHOR,'CNE', CNE.R_E_C_N_O_, '" + DTOS(DATE()) + "', '" + SUBSTR(TIME(),1,5) + "', '" + __CUSERID + "' " + CRLF +;	
		"FROM "+RetSqlName("CNE")+ " CNE WITH (NOLOCK),"+RetSqlName("CN9")+ " CN9 WITH (NOLOCK), "+RetSqlName("ZZ0")+ " ZZ0 WITH (NOLOCK) " + CRLF +;
		"WHERE CNE.D_E_L_E_T_ = ' ' " + CRLF +;
		"AND CN9.D_E_L_E_T_ = ' ' " + CRLF +;
		"AND ZZ0.D_E_L_E_T_ = ' ' " + CRLF +; 
		"AND SUBSTRING(CNE_FILIAL,1,4) = '"+SubString(xFilial("CNE"),1,4)+"' " + CRLF +;
		"AND CN9_FILIAL = CNE_FILIAL " + CRLF +;
		"AND CN9_NUMERO = CNE_CONTRA " + CRLF +;
		"AND CN9_REVISA = CNE_REVISA " + CRLF +;
		"AND CN9_SITUAC = '05' " + CRLF +;
		"AND ZZ0_EXERC = '"+MV_PAR01+"' " + CRLF +;
		"AND ZZ0_ENTID = '"+MV_PAR05+"' " + CRLF +;
		"AND ZZ0_PROCES = '1' " + CRLF +;
		"AND SUBSTRING(ZZ0_FILIAL,1,4) = SUBSTRING(CNE_FILIAL,1,4) " 
		DO CASE
		  	CASE MV_PAR05 == "1"
		  		cQuery += CRLF + "AND CNE_CONTA = ZZ0_EN_ATU "
		  	CASE MV_PAR05 == "2"
		  		cQuery += CRLF + "AND CNE_CC = ZZ0_EN_ATU "
		  	CASE MV_PAR05 == "3"
		  		cQuery += CRLF + "AND CNE_ITEMCT = ZZ0_EN_ATU "
		  	CASE MV_PAR05 == "4"
		  		cQuery += CRLF + "AND CNE_CLVL = ZZ0_EN_ATU "
		ENDCASE
		IF !EMPTY(MV_PAR02)
			cQuery += CRLF + "AND CNE_CC = '"+MV_PAR02+"' "
	    ENDIF
		IF !EMPTY(MV_PAR03)
			cQuery += CRLF + "AND CNE_ITEMCT = '"+MV_PAR03+"' "
	    ENDIF
		IF !EMPTY(MV_PAR04)
			cQuery += CRLF + "AND CNE_CONTA = '"+MV_PAR04+"' "
	    ENDIF	
		FWrite(nHdl,cQuery + CHR(13)+CHR(10))
		FWrite(nHdl," " + CHR(13)+CHR(10) )
		TcSqlExec(cQuery)
		
		cQuery := +;
		"UPDATE "+RetSqlName("CNE")+" "
		DO CASE
		  	CASE MV_PAR05 == "1"
		  		cQuery += CRLF + "SET CNE_CONTA = ZZ0_EN_NEW "
		  	CASE MV_PAR05 == "2"
		  		cQuery += CRLF + "SET CNE_CC = ZZ0_EN_NEW "
		  	CASE MV_PAR05 == "3"
		  		cQuery += CRLF + "SET CNE_ITEMCT = ZZ0_EN_NEW "
		  	CASE MV_PAR05 == "4"
		  		cQuery += CRLF + "SET CNE_CLVL = ZZ0_EN_NEW "
		ENDCASE
		cQuery += CRLF +; 
		"FROM "+RetSqlName("CNE")+ " CNE WITH (NOLOCK),"+RetSqlName("CN9")+ " CN9 WITH (NOLOCK), "+RetSqlName("ZZ0")+ " ZZ0 WITH (NOLOCK) " + CRLF +;
		"WHERE CNE.D_E_L_E_T_ = ' ' " + CRLF +;
		"AND CN9.D_E_L_E_T_ = ' ' " + CRLF +;
		"AND ZZ0.D_E_L_E_T_ = ' ' " + CRLF +; 
		"AND SUBSTRING(CNE_FILIAL,1,4) = '"+SubString(xFilial("CNE"),1,4)+"' " + CRLF +;
		"AND CN9_FILIAL = CNE_FILIAL " + CRLF +;
		"AND CN9_NUMERO = CNE_CONTRA " + CRLF +;
		"AND CN9_REVISA = CNE_REVISA " + CRLF +;
		"AND CN9_SITUAC = '05' " + CRLF +;
		"AND ZZ0_EXERC = '"+MV_PAR01+"' " + CRLF +;
		"AND ZZ0_ENTID = '"+MV_PAR05+"' " + CRLF +;
		"AND ZZ0_PROCES = '1' " + CRLF +;
		"AND SUBSTRING(ZZ0_FILIAL,1,4) = SUBSTRING(CNE_FILIAL,1,4) " 
		DO CASE
		  	CASE MV_PAR05 == "1"
		  		cQuery += CRLF + "AND CNE_CONTA = ZZ0_EN_ATU "
		  	CASE MV_PAR05 == "2"
		  		cQuery += CRLF + "AND CNE_CC = ZZ0_EN_ATU "
		  	CASE MV_PAR05 == "3"
		  		cQuery += CRLF + "AND CNE_ITEMCT = ZZ0_EN_ATU "
		  	CASE MV_PAR05 == "4"
		  		cQuery += CRLF + "AND CNE_CLVL = ZZ0_EN_ATU "
		ENDCASE
		IF !EMPTY(MV_PAR02)
			cQuery += CRLF + "AND CNE_CC = '"+MV_PAR02+"' "
	    ENDIF
		IF !EMPTY(MV_PAR03)
			cQuery += CRLF + "AND CNE_ITEMCT = '"+MV_PAR03+"' "
	    ENDIF
		IF !EMPTY(MV_PAR04)
			cQuery += CRLF + "AND CNE_CONTA = '"+MV_PAR04+"' "
	    ENDIF	
		FWrite(nHdl,cQuery + CHR(13)+CHR(10))
		FWrite(nHdl," " + CHR(13)+CHR(10) )
		TcSqlExec(cQuery) 
	ELSE
		DbCloseArea()	
	ENDIF	
ENDIF	


//ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
//บ Cadastro de Bancos                                               บ
//ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
IF MV_PAR11 == 1
	cQuery := +;
	"SELECT A6_FILIAL, A6_COD, A6_AGENCIA, A6_NUMCON, A6_CONTA, A6_XUO, ZZ0_ENTID, ZZ0_EN_ATU, ZZ0_EN_NEW, SA6.R_E_C_N_O_ " + CRLF +;
	"FROM "+RetSqlName("SA6")+ " SA6 WITH (NOLOCK),"+RetSqlName("ZZ0")+ " ZZ0 WITH (NOLOCK) " + CRLF +;
	"WHERE SA6.D_E_L_E_T_ = ' ' " + CRLF +;
	"AND ZZ0.D_E_L_E_T_ = ' ' " + CRLF +; 
	"AND SUBSTRING(A6_FILIAL,1,4) = '"+SubString(xFilial("SA6"),1,4)+"' " + CRLF +;
	"AND ZZ0_EXERC = '"+MV_PAR01+"' " + CRLF +;
	"AND ZZ0_ENTID = '"+MV_PAR05+"' " + CRLF +;
	"AND ZZ0_PROCES = '1' " + CRLF +;
	"AND SUBSTRING(ZZ0_FILIAL,1,4) = SUBSTRING(A6_FILIAL,1,4) " 
	DO CASE
	  	CASE MV_PAR05 == "1"
	  		cQuery += CRLF + "AND A6_CONTA = ZZ0_EN_ATU "
	  	CASE MV_PAR05 == "2"
	  		cQuery += CRLF + "AND A6_XUO = ZZ0_EN_ATU "
	  	OTHERWISE	                           
	  		cQuery += CRLF + "AND 0 = 1 "
	ENDCASE
	IF !EMPTY(MV_PAR02)
		cQuery += CRLF + "AND A6_XUO = '"+MV_PAR02+"' "
    ENDIF
	IF !EMPTY(MV_PAR04)
		cQuery += CRLF + "AND A6_CONTA = '"+MV_PAR04+"' "
    ENDIF	
	cQuery += CRLF + "ORDER BY A6_FILIAL "
	DbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), "QRY", .T., .T.)
	Count to nCount

	FWrite(nHdl,"=========================================================================================================================================================================" + CHR(13)+CHR(10) )
	FWrite(nHdl,cQuery + CHR(13)+CHR(10))
	FWrite(nHdl," " + CHR(13)+CHR(10) )

	_MSG += ALLTRIM(STR(nCount)) + ' registro(s) de cadastro de banco' + CRLF

	IF nCount > 0	
		DbSelectArea("QRY")
		DbGoTop()
		While !Eof()
			cEntid := ""
		    If ZZ0_ENTID == '1'
		    	cEntid := "Conta Contabil"
				FWrite(nHdl,"BANCOS | "+A6_FILIAL+" | "+A6_COD+" "+A6_AGENCIA+" "+A6_NUMCON+" | "+cEntid+" | "+A6_CONTA+" | "+ZZ0_EN_NEW+" | "+ALLTRIM(STR(R_E_C_N_O_)) + CHR(13)+CHR(10) )
		    Elseif ZZ0_ENTID == '2'
		    	cEntid := "Centro de Custo"
				FWrite(nHdl,"BANCOS | "+A6_FILIAL+" | "+A6_COD+" "+A6_AGENCIA+" "+A6_NUMCON+" | "+cEntid+" | "+A6_XUO+" | "+ZZ0_EN_NEW+" | "+ALLTRIM(STR(R_E_C_N_O_)) + CHR(13)+CHR(10) )
			Endif
			DbSkip()
		End	
		FWrite(nHdl,"" + CHR(13)+CHR(10) )
		DbCloseArea()		
	
		cQuery := +;
		"INSERT INTO ZZ1010(ZZ1_FILIAL,ZZ1_EXERC,ZZ1_ENTID,ZZ1_EN_ATU,ZZ1_EN_NEW,ZZ1_DATHOR,ZZ1_TABELA,ZZ1_RECNO,ZZ1_DATA,ZZ1_HORA,ZZ1_USERGI) " + CRLF +;	
		"SELECT ZZ0_FILIAL, ZZ0_EXERC, ZZ0_ENTID, ZZ0_EN_ATU, ZZ0_EN_NEW, ZZ0_DATHOR,'SA6', SA6.R_E_C_N_O_, '" + DTOS(DATE()) + "', '" + SUBSTR(TIME(),1,5) + "', '" + __CUSERID + "' " + CRLF +;	
		"FROM "+RetSqlName("SA6")+ " SA6 WITH (NOLOCK),"+RetSqlName("ZZ0")+ " ZZ0 WITH (NOLOCK) " + CRLF +;
		"WHERE SA6.D_E_L_E_T_ = ' ' " + CRLF +;
		"AND ZZ0.D_E_L_E_T_ = ' ' " + CRLF +; 
		"AND SUBSTRING(A6_FILIAL,1,4) = '"+SubString(xFilial("SA6"),1,4)+"' " + CRLF +;
		"AND ZZ0_EXERC = '"+MV_PAR01+"' " + CRLF +;
		"AND ZZ0_ENTID = '"+MV_PAR05+"' " + CRLF +;
		"AND ZZ0_PROCES = '1' " + CRLF +;
		"AND SUBSTRING(ZZ0_FILIAL,1,4) = SUBSTRING(A6_FILIAL,1,4) " 
		DO CASE
		  	CASE MV_PAR05 == "1"
		  		cQuery += CRLF + "AND A6_CONTA = ZZ0_EN_ATU "
		  	CASE MV_PAR05 == "2"
		  		cQuery += CRLF + "AND A6_XUO = ZZ0_EN_ATU "    
		  	OTHERWISE	                           
		  		cQuery += CRLF + "AND 0 = 1 "
		ENDCASE
		IF !EMPTY(MV_PAR02)
			cQuery += CRLF + "AND A6_XUO = '"+MV_PAR02+"' "
	    ENDIF
		IF !EMPTY(MV_PAR04)
			cQuery += CRLF + "AND A6_CONTA = '"+MV_PAR04+"' "
	    ENDIF		
		FWrite(nHdl,cQuery + CHR(13)+CHR(10))
		FWrite(nHdl," " + CHR(13)+CHR(10) )
		TcSqlExec(cQuery)
		
		cQuery := +;
		"UPDATE "+RetSqlName("SA6")+" "
		DO CASE
		  	CASE MV_PAR05 == "1"
		  		cQuery += CRLF + "SET A6_CONTA = ZZ0_EN_NEW "
		  	CASE MV_PAR05 == "2"
		  		cQuery += CRLF + "SET A6_XUO = ZZ0_EN_NEW "
		ENDCASE     
		cQuery += CRLF +; 
		"FROM "+RetSqlName("SA6")+ " SA6 WITH (NOLOCK),"+RetSqlName("ZZ0")+ " ZZ0 WITH (NOLOCK) " + CRLF +;
		"WHERE SA6.D_E_L_E_T_ = ' ' " + CRLF +;
		"AND ZZ0.D_E_L_E_T_ = ' ' " + CRLF +; 
		"AND SUBSTRING(A6_FILIAL,1,4) = '"+SubString(xFilial("SA6"),1,4)+"' " + CRLF +;
		"AND ZZ0_EXERC = '"+MV_PAR01+"' " + CRLF +;
		"AND ZZ0_ENTID = '"+MV_PAR05+"' " + CRLF +;
		"AND ZZ0_PROCES = '1' " + CRLF +;
		"AND SUBSTRING(ZZ0_FILIAL,1,4) = SUBSTRING(A6_FILIAL,1,4) " 
		DO CASE
		  	CASE MV_PAR05 == "1"
		  		cQuery += CRLF + "AND A6_CONTA = ZZ0_EN_ATU "
		  	CASE MV_PAR05 == "2"
		  		cQuery += CRLF + "AND A6_XUO = ZZ0_EN_ATU "
		  	OTHERWISE	                           
		  		cQuery += CRLF + "AND 0 = 1 "
		ENDCASE
		IF !EMPTY(MV_PAR02)
			cQuery += CRLF + "AND A6_XUO = '"+MV_PAR02+"' "
	    ENDIF
		IF !EMPTY(MV_PAR04)
			cQuery += CRLF + "AND A6_CONTA = '"+MV_PAR04+"' "
	    ENDIF		
		FWrite(nHdl,cQuery + CHR(13)+CHR(10))
		FWrite(nHdl," " + CHR(13)+CHR(10) )
		TcSqlExec(cQuery) 
	ELSE
		DbCloseArea()	
	ENDIF	
ENDIF	


//ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
//บ Contas a Receber                                                        บ
//ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
IF MV_PAR12 == 1
	cQuery := +;
	"SELECT E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_EMISSAO, E1_CREDIT, E1_CCC, E1_ITEMC, E1_CLVLCR, ZZ0_ENTID, ZZ0_EN_ATU, ZZ0_EN_NEW, SE1.R_E_C_N_O_ " + CRLF +;	
	"FROM "+RetSqlName("SE1")+ " SE1 WITH (NOLOCK),"+RetSqlName("ZZ0")+ " ZZ0 WITH (NOLOCK) " + CRLF +;
	"WHERE SE1.D_E_L_E_T_ = ' ' " + CRLF +;
	"AND ZZ0.D_E_L_E_T_ = ' ' " + CRLF +;
	"AND SUBSTRING(E1_FILIAL,1,4) = '"+SubString(xFilial("SE1"),1,4)+"' " + CRLF +;
	"AND E1_SALDO > 0 " + CRLF +;
	"AND YEAR(E1_EMISSAO) >= "+ALLTRIM(STR(VAL(MV_PAR01) - 1))+" " + CRLF +;
	"AND ZZ0_EXERC = '"+MV_PAR01+"' " + CRLF +;
	"AND ZZ0_ENTID = '"+MV_PAR05+"' " + CRLF +;
	"AND ZZ0_PROCES = '1' " + CRLF +;
	"AND SUBSTRING(ZZ0_FILIAL,1,4) = SUBSTRING(E1_FILIAL,1,4) " 
	DO CASE
	  	CASE MV_PAR05 == "1"
	  		cQuery += CRLF + "AND E1_CREDIT = ZZ0_EN_ATU "
	  	CASE MV_PAR05 == "2"
	  		cQuery += CRLF + "AND E1_CCC = ZZ0_EN_ATU "
	  	CASE MV_PAR05 == "3"
	  		cQuery += CRLF + "AND E1_ITEMC = ZZ0_EN_ATU "
	  	CASE MV_PAR05 == "4"
	  		cQuery += CRLF + "AND E1_CLVLCR = ZZ0_EN_ATU "
	ENDCASE
	IF !EMPTY(MV_PAR02)
		cQuery += CRLF + "AND E1_CCC = '"+MV_PAR02+"' "
    ENDIF
	IF !EMPTY(MV_PAR03)
		cQuery += CRLF + "AND E1_ITEMC = '"+MV_PAR03+"' "
    ENDIF
	IF !EMPTY(MV_PAR04)
		cQuery += CRLF + "AND E1_CREDIT = '"+MV_PAR04+"' "
    ENDIF
	cQuery += CRLF + "ORDER BY E1_FILIAL "
	DbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), "QRY", .T., .T.)
	Count to nCount
	TcSetField("QRY", "E1_EMISSAO", "D", 08, 0)

	FWrite(nHdl,"=========================================================================================================================================================================" + CHR(13)+CHR(10) )
	FWrite(nHdl,cQuery + CHR(13)+CHR(10))
	FWrite(nHdl," " + CHR(13)+CHR(10) )

	_MSG += ALLTRIM(STR(nCount)) + ' registro(s) de contas a receber' + CRLF

	IF nCount > 0	
		DbSelectArea("QRY")
		DbGoTop()
		While !Eof()
			cEntid := ""
		    If ZZ0_ENTID == '1'
		    	cEntid := "Conta Contabil"
				FWrite(nHdl,"CONTAS A RECEBER | "+E1_FILIAL+" | "+E1_PREFIXO+" "+E1_NUM+" "+E1_PARCELA+" | "+Dtoc(E1_EMISSAO)+" | "+cEntid+" | "+E1_CREDIT+" | "+ZZ0_EN_NEW+" | "+ALLTRIM(STR(R_E_C_N_O_)) + CHR(13)+CHR(10) )
		    Elseif ZZ0_ENTID == '2'
		    	cEntid := "Centro de Custo"
				FWrite(nHdl,"CONTAS A RECEBER | "+E1_FILIAL+" | "+E1_PREFIXO+" "+E1_NUM+" "+E1_PARCELA+" | "+Dtoc(E1_EMISSAO)+" | "+cEntid+" | "+E1_CCC+" | "+ZZ0_EN_NEW+" | "+ALLTRIM(STR(R_E_C_N_O_)) + CHR(13)+CHR(10) )
		    Elseif ZZ0_ENTID == '3'
		    	cEntid := "Item Contabil"
				FWrite(nHdl,"CONTAS A RECEBER | "+E1_FILIAL+" | "+E1_PREFIXO+" "+E1_NUM+" "+E1_PARCELA+" | "+Dtoc(E1_EMISSAO)+" | "+cEntid+" | "+E1_ITEMC+" | "+ZZ0_EN_NEW+" | "+ALLTRIM(STR(R_E_C_N_O_)) + CHR(13)+CHR(10) )
		    Elseif ZZ0_ENTID == '4'
		    	cEntid := "Classe de Valor"
				FWrite(nHdl,"CONTAS A RECEBER | "+E1_FILIAL+" | "+E1_PREFIXO+" "+E1_NUM+" "+E1_PARCELA+" | "+Dtoc(E1_EMISSAO)+" | "+cEntid+" | "+E1_CLVLCR+" | "+ZZ0_EN_NEW+" | "+ALLTRIM(STR(R_E_C_N_O_)) + CHR(13)+CHR(10) )
			Endif
			DbSkip()
		End	
		FWrite(nHdl,"" + CHR(13)+CHR(10) )
		DbCloseArea()		
		
		cQuery := +;
		"INSERT INTO ZZ1010(ZZ1_FILIAL,ZZ1_EXERC,ZZ1_ENTID,ZZ1_EN_ATU,ZZ1_EN_NEW,ZZ1_DATHOR,ZZ1_TABELA,ZZ1_RECNO,ZZ1_DATA,ZZ1_HORA,ZZ1_USERGI) " + CRLF +;	
		"SELECT ZZ0_FILIAL, ZZ0_EXERC, ZZ0_ENTID, ZZ0_EN_ATU, ZZ0_EN_NEW, ZZ0_DATHOR,'SE1', SE1.R_E_C_N_O_, '" + DTOS(DATE()) + "', '" + SUBSTR(TIME(),1,5) + "', '" + __CUSERID + "' " + CRLF +;	
		"FROM "+RetSqlName("SE1")+ " SE1 WITH (NOLOCK),"+RetSqlName("ZZ0")+ " ZZ0 WITH (NOLOCK) " + CRLF +;
		"WHERE SE1.D_E_L_E_T_ = ' ' " + CRLF +;
		"AND ZZ0.D_E_L_E_T_ = ' ' " + CRLF +; 
		"AND SUBSTRING(E1_FILIAL,1,4) = '"+SubString(xFilial("SE1"),1,4)+"' " + CRLF +;
		"AND E1_SALDO > 0 " + CRLF +;
		"AND YEAR(E1_EMISSAO) >= "+ALLTRIM(STR(VAL(MV_PAR01) - 1))+" " + CRLF +;
		"AND ZZ0_EXERC = '"+MV_PAR01+"' " + CRLF +;
		"AND ZZ0_ENTID = '"+MV_PAR05+"' " + CRLF +;
		"AND ZZ0_PROCES = '1' " + CRLF +;
		"AND SUBSTRING(ZZ0_FILIAL,1,4) = SUBSTRING(E1_FILIAL,1,4) " 
		DO CASE
		  	CASE MV_PAR05 == "1"
		  		cQuery += CRLF + "AND E1_CREDIT = ZZ0_EN_ATU "
		  	CASE MV_PAR05 == "2"
		  		cQuery += CRLF + "AND E1_CCC = ZZ0_EN_ATU "
		  	CASE MV_PAR05 == "3"
		  		cQuery += CRLF + "AND E1_ITEMC = ZZ0_EN_ATU "
		  	CASE MV_PAR05 == "4"
		  		cQuery += CRLF + "AND E1_CLVLCR = ZZ0_EN_ATU "
		ENDCASE
		IF !EMPTY(MV_PAR02)
			cQuery += CRLF + "AND E1_CCC = '"+MV_PAR02+"' "
	    ENDIF
		IF !EMPTY(MV_PAR03)
			cQuery += CRLF + "AND E1_ITEMC = '"+MV_PAR03+"' "
	    ENDIF
		IF !EMPTY(MV_PAR04)
			cQuery += CRLF + "AND E1_CREDIT = '"+MV_PAR04+"' "
	    ENDIF	
		FWrite(nHdl,cQuery + CHR(13)+CHR(10))
		FWrite(nHdl," " + CHR(13)+CHR(10) )
		TcSqlExec(cQuery)
		
		cQuery := +;
		"UPDATE "+RetSqlName("SE1")+" "
		DO CASE
		  	CASE MV_PAR05 == "1"
		  		cQuery += CRLF + "SET E1_CREDIT = ZZ0_EN_NEW "
		  	CASE MV_PAR05 == "2"
		  		cQuery += CRLF + "SET E1_CCC = ZZ0_EN_NEW "
		  	CASE MV_PAR05 == "3"
		  		cQuery += CRLF + "SET E1_ITEMC = ZZ0_EN_NEW "
		  	CASE MV_PAR05 == "4"
		  		cQuery += CRLF + "SET E1_CLVLCR = ZZ0_EN_NEW "
		ENDCASE
		cQuery += CRLF +;
		"FROM "+RetSqlName("SE1")+ " SE1 WITH (NOLOCK),"+RetSqlName("ZZ0")+ " ZZ0 WITH (NOLOCK) " + CRLF +;
		"WHERE SE1.D_E_L_E_T_ = ' ' " + CRLF +;
		"AND ZZ0.D_E_L_E_T_ = ' ' " + CRLF +; 
		"AND SUBSTRING(E1_FILIAL,1,4) = '"+SubString(xFilial("SE1"),1,4)+"' " + CRLF +;
		"AND E1_SALDO > 0 " + CRLF +;
		"AND YEAR(E1_EMISSAO) >= "+ALLTRIM(STR(VAL(MV_PAR01) - 1))+" " + CRLF +;
		"AND ZZ0_EXERC = '"+MV_PAR01+"' " + CRLF +;
		"AND ZZ0_ENTID = '"+MV_PAR05+"' " + CRLF +;
		"AND ZZ0_PROCES = '1' " + CRLF +;
		"AND SUBSTRING(ZZ0_FILIAL,1,4) = SUBSTRING(E1_FILIAL,1,4) " 
		DO CASE
		  	CASE MV_PAR05 == "1"
		  		cQuery += CRLF + "AND E1_CREDIT = ZZ0_EN_ATU "
		  	CASE MV_PAR05 == "2"
		  		cQuery += CRLF + "AND E1_CCC = ZZ0_EN_ATU "
		  	CASE MV_PAR05 == "3"
		  		cQuery += CRLF + "AND E1_ITEMC = ZZ0_EN_ATU "
		  	CASE MV_PAR05 == "4"
		  		cQuery += CRLF + "AND E1_CLVLCR = ZZ0_EN_ATU "
		ENDCASE
		IF !EMPTY(MV_PAR02)
			cQuery += CRLF + "AND E1_CCC = '"+MV_PAR02+"' "
	    ENDIF
		IF !EMPTY(MV_PAR03)
			cQuery += CRLF + "AND E1_ITEMC = '"+MV_PAR03+"' "
	    ENDIF
		IF !EMPTY(MV_PAR04)
			cQuery += CRLF + "AND E1_CREDIT = '"+MV_PAR04+"' "
	    ENDIF			
		FWrite(nHdl,cQuery + CHR(13)+CHR(10))
		FWrite(nHdl," " + CHR(13)+CHR(10) )
		TcSqlExec(cQuery) 
	ELSE
		DbCloseArea()	
	ENDIF	
ENDIF	   


//ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
//บ Contas a Pagar                                                          บ
//ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
IF MV_PAR13 == 1
	cQuery := +;
	"SELECT E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_EMISSAO, E2_CONTAD, E2_CCD, E2_ITEMD, E2_CLVLDB, ZZ0_ENTID, ZZ0_EN_ATU, ZZ0_EN_NEW, SE2.R_E_C_N_O_ " + CRLF +;	
	"FROM "+RetSqlName("SE2")+ " SE2 WITH (NOLOCK),"+RetSqlName("ZZ0")+ " ZZ0 WITH (NOLOCK) " + CRLF +;
	"WHERE SE2.D_E_L_E_T_ = ' ' " + CRLF +;
	"AND ZZ0.D_E_L_E_T_ = ' ' " + CRLF +; 
	"AND SUBSTRING(E2_FILIAL,1,4) = '"+SubString(xFilial("SE2"),1,4)+"' " + CRLF +;
	"AND E2_SALDO > 0 " + CRLF +;
	"AND YEAR(E2_EMISSAO) >= "+ALLTRIM(STR(VAL(MV_PAR01) - 1))+" " + CRLF +;
	"AND ZZ0_EXERC = '"+MV_PAR01+"' " + CRLF +;
	"AND ZZ0_ENTID = '"+MV_PAR05+"' " + CRLF +;
	"AND ZZ0_PROCES = '1' " + CRLF +;
	"AND SUBSTRING(ZZ0_FILIAL,1,4) = SUBSTRING(E2_FILIAL,1,4) " 
	DO CASE
	  	CASE MV_PAR05 == "1"
	  		cQuery += CRLF + "AND E2_CONTAD = ZZ0_EN_ATU "
	  	CASE MV_PAR05 == "2"
	  		cQuery += CRLF + "AND E2_CCD = ZZ0_EN_ATU "
	  	CASE MV_PAR05 == "3"
	  		cQuery += CRLF + "AND E2_ITEMD = ZZ0_EN_ATU "
	  	CASE MV_PAR05 == "4"
	  		cQuery += CRLF + "AND E2_CLVLDB = ZZ0_EN_ATU "
	ENDCASE  
	IF !EMPTY(MV_PAR02)
		cQuery += CRLF + "AND E2_CCD = '"+MV_PAR02+"' "
    ENDIF
	IF !EMPTY(MV_PAR03)
		cQuery += CRLF + "AND E2_ITEMD = '"+MV_PAR03+"' "
    ENDIF
	IF !EMPTY(MV_PAR04)
		cQuery += CRLF + "AND E2_CONTAD = '"+MV_PAR04+"' "
    ENDIF	
	cQuery += CRLF + "ORDER BY E2_FILIAL "
	DbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), "QRY", .T., .T.)
	Count to nCount
	TcSetField("QRY", "E2_EMISSAO", "D", 08, 0)

	FWrite(nHdl,"=========================================================================================================================================================================" + CHR(13)+CHR(10) )
	FWrite(nHdl,cQuery + CHR(13)+CHR(10))
	FWrite(nHdl," " + CHR(13)+CHR(10) )

	_MSG += ALLTRIM(STR(nCount)) + ' registro(s) de contas a pagar' + CRLF

	IF nCount > 0	
		DbSelectArea("QRY")
		DbGoTop()
		While !Eof()
			cEntid := ""
		    If ZZ0_ENTID == '1'
		    	cEntid := "Conta Contabil"
				FWrite(nHdl,"CONTAS A PAGAR | "+E2_FILIAL+" | "+E2_PREFIXO+" "+E2_NUM+" "+E2_PARCELA+" | "+Dtoc(E2_EMISSAO)+" | "+cEntid+" | "+E2_CONTAD+" | "+ZZ0_EN_NEW+" | "+ALLTRIM(STR(R_E_C_N_O_)) + CHR(13)+CHR(10) )
		    Elseif ZZ0_ENTID == '2'
		    	cEntid := "Centro de Custo"
				FWrite(nHdl,"CONTAS A PAGAR | "+E2_FILIAL+" | "+E2_PREFIXO+" "+E2_NUM+" "+E2_PARCELA+" | "+Dtoc(E2_EMISSAO)+" | "+cEntid+" | "+E2_CCD+" | "+ZZ0_EN_NEW+" | "+ALLTRIM(STR(R_E_C_N_O_)) + CHR(13)+CHR(10) )
		    Elseif ZZ0_ENTID == '3'
		    	cEntid := "Item Contabil"
				FWrite(nHdl,"CONTAS A PAGAR | "+E2_FILIAL+" | "+E2_PREFIXO+" "+E2_NUM+" "+E2_PARCELA+" | "+Dtoc(E2_EMISSAO)+" | "+cEntid+" | "+E2_ITEMD+" | "+ZZ0_EN_NEW+" | "+ALLTRIM(STR(R_E_C_N_O_)) + CHR(13)+CHR(10) )
		    Elseif ZZ0_ENTID == '4'
		    	cEntid := "Classe de Valor"
				FWrite(nHdl,"CONTAS A PAGAR | "+E2_FILIAL+" | "+E2_PREFIXO+" "+E2_NUM+" "+E2_PARCELA+" | "+Dtoc(E2_EMISSAO)+" | "+cEntid+" | "+E2_CLVLDB+" | "+ZZ0_EN_NEW+" | "+ALLTRIM(STR(R_E_C_N_O_)) + CHR(13)+CHR(10) )
			Endif
			DbSkip()
		End	
		FWrite(nHdl,"" + CHR(13)+CHR(10) )
		DbCloseArea()		
		
		cQuery := +;
		"INSERT INTO ZZ1010(ZZ1_FILIAL,ZZ1_EXERC,ZZ1_ENTID,ZZ1_EN_ATU,ZZ1_EN_NEW,ZZ1_DATHOR,ZZ1_TABELA,ZZ1_RECNO,ZZ1_DATA,ZZ1_HORA,ZZ1_USERGI) " + CRLF +;
		"SELECT ZZ0_FILIAL, ZZ0_EXERC, ZZ0_ENTID, ZZ0_EN_ATU, ZZ0_EN_NEW, ZZ0_DATHOR,'SE2', SE2.R_E_C_N_O_, '" + DTOS(DATE()) + "', '" + SUBSTR(TIME(),1,5) + "', '" + __CUSERID + "' " + CRLF +;	
		"FROM "+RetSqlName("SE2")+ " SE2 WITH (NOLOCK),"+RetSqlName("ZZ0")+ " ZZ0 WITH (NOLOCK) " + CRLF +;
		"WHERE SE2.D_E_L_E_T_ = ' ' " + CRLF +;
		"AND ZZ0.D_E_L_E_T_ = ' ' " + CRLF +; 
		"AND SUBSTRING(E2_FILIAL,1,4) = '"+SubString(xFilial("SE2"),1,4)+"' " + CRLF +;
		"AND E2_SALDO > 0 " + CRLF +;
		"AND YEAR(E2_EMISSAO) >= "+ALLTRIM(STR(VAL(MV_PAR01) - 1))+" " + CRLF +;
		"AND ZZ0_EXERC = '"+MV_PAR01+"' " + CRLF +;
		"AND ZZ0_ENTID = '"+MV_PAR05+"' " + CRLF +;
		"AND ZZ0_PROCES = '1' " + CRLF +;
		"AND SUBSTRING(ZZ0_FILIAL,1,4) = SUBSTRING(E2_FILIAL,1,4) "
		DO CASE
		  	CASE MV_PAR05 == "1"
		  		cQuery += CRLF + "AND E2_CONTAD = ZZ0_EN_ATU "
		  	CASE MV_PAR05 == "2"
		  		cQuery += CRLF + "AND E2_CCD = ZZ0_EN_ATU "
		  	CASE MV_PAR05 == "3"
		  		cQuery += CRLF + "AND E2_ITEMD = ZZ0_EN_ATU "
		  	CASE MV_PAR05 == "4"
		  		cQuery += CRLF + "AND E2_CLVLDB = ZZ0_EN_ATU "
		ENDCASE
		IF !EMPTY(MV_PAR02)
			cQuery += CRLF + "AND E2_CCD = '"+MV_PAR02+"' "
	    ENDIF
		IF !EMPTY(MV_PAR03)
			cQuery += CRLF + "AND E2_ITEMD = '"+MV_PAR03+"' "
	    ENDIF
		IF !EMPTY(MV_PAR04)
			cQuery += CRLF + "AND E2_CONTAD = '"+MV_PAR04+"' "
	    ENDIF				
		FWrite(nHdl,cQuery + CHR(13)+CHR(10))
		FWrite(nHdl," " + CHR(13)+CHR(10) )
		TcSqlExec(cQuery)
		
		cQuery := +;
		"UPDATE "+RetSqlName("SE2")+" "
		DO CASE
		  	CASE MV_PAR05 == "1"
		  		cQuery += CRLF + "SET E2_CONTAD = ZZ0_EN_NEW "
		  	CASE MV_PAR05 == "2"
		  		cQuery += CRLF + "SET E2_CCD = ZZ0_EN_NEW "
		  	CASE MV_PAR05 == "3"
		  		cQuery += CRLF + "SET E2_ITEMD = ZZ0_EN_NEW "
		  	CASE MV_PAR05 == "4"
		  		cQuery += CRLF + "SET E2_CLVLDB = ZZ0_EN_NEW "
		ENDCASE
		cQuery += CRLF +;
		"FROM "+RetSqlName("SE2")+ " SE2 WITH (NOLOCK),"+RetSqlName("ZZ0")+ " ZZ0 WITH (NOLOCK) " + CRLF +;
		"WHERE SE2.D_E_L_E_T_ = ' ' " + CRLF +;
		"AND ZZ0.D_E_L_E_T_ = ' ' " + CRLF +; 
		"AND SUBSTRING(E2_FILIAL,1,4) = '"+SubString(xFilial("SE2"),1,4)+"' " + CRLF +;
		"AND E2_SALDO > 0 " + CRLF +;
		"AND YEAR(E2_EMISSAO) >= "+ALLTRIM(STR(VAL(MV_PAR01) - 1))+" " + CRLF +;
		"AND ZZ0_EXERC = '"+MV_PAR01+"' " + CRLF +;
		"AND ZZ0_ENTID = '"+MV_PAR05+"' " + CRLF +;
		"AND ZZ0_PROCES = '1' " + CRLF +;
		"AND SUBSTRING(ZZ0_FILIAL,1,4) = SUBSTRING(E2_FILIAL,1,4) " 
		DO CASE
		  	CASE MV_PAR05 == "1"
		  		cQuery += CRLF + "AND E2_CONTAD = ZZ0_EN_ATU "
		  	CASE MV_PAR05 == "2"
		  		cQuery += CRLF + "AND E2_CCD = ZZ0_EN_ATU "
		  	CASE MV_PAR05 == "3"
		  		cQuery += CRLF + "AND E2_ITEMD = ZZ0_EN_ATU "
		  	CASE MV_PAR05 == "4"
		  		cQuery += CRLF + "AND E2_CLVLDB = ZZ0_EN_ATU "
		ENDCASE    
		IF !EMPTY(MV_PAR02)
			cQuery += CRLF + "AND E2_CCD = '"+MV_PAR02+"' "
	    ENDIF
		IF !EMPTY(MV_PAR03)
			cQuery += CRLF + "AND E2_ITEMD = '"+MV_PAR03+"' "
	    ENDIF
		IF !EMPTY(MV_PAR04)
			cQuery += CRLF + "AND E2_CONTAD = '"+MV_PAR04+"' "
	    ENDIF				
		FWrite(nHdl,cQuery + CHR(13)+CHR(10))
		FWrite(nHdl," " + CHR(13)+CHR(10) )
		TcSqlExec(cQuery) 
	ELSE
		DbCloseArea()	
	ENDIF	
ENDIF	


//ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
//บ Ativo Imobilizado                                                บ
//ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
/*
cQuery := +;
"INSERT INTO ZZ1010(ZZ1_FILIAL,ZZ1_EXERC,ZZ1_ENTID,ZZ1_EN_ATU,ZZ1_EN_NEW,ZZ1_DATHOR,ZZ1_TABELA,ZZ1_RECNO,ZZ1_DATA,ZZ1_HORA,ZZ1_USERGI) " + CRLF +;	
"SELECT ZZ0_FILIAL, ZZ0_EXERC, ZZ0_ENTID, ZZ0_EN_ATU, ZZ0_EN_NEW, ZZ0_DATHOR,'SN3', SN3.R_E_C_N_O_, '" + DTOS(DATE()) + "', '" + SUBSTR(TIME(),1,5) + "', '" + __CUSERID + "' " + CRLF +;	
"FROM "+RetSqlName("SN3")+ " SN3 WITH (NOLOCK),"+RetSqlName("ZZ0")+ " ZZ0 WITH (NOLOCK) " + CRLF +;
"WHERE SN3.D_E_L_E_T_ = ' ' " + CRLF +;
"AND ZZ0.D_E_L_E_T_ = ' ' " + CRLF +;
"AND N3_SALDO > 0 " + CRLF +; 
"AND YEAR(N3_AQUISIC) >= "+ALLTRIM(STR(VAL(MV_PAR01) - 1))+" " + CRLF +;
"AND ZZ0_EXERC = '"+MV_PAR01+"' " + CRLF +;
"AND ZZ0_ENTID = '"+MV_PAR05+"' " + CRLF +;
"AND ZZ0_PROCES = '1' "
DO CASE
  	CASE MV_PAR05 == "1"
  		cQuery += CRLF + "AND N3_CONTAD = ZZ0_EN_ATU "
  	CASE MV_PAR05 == "2"
  		cQuery += CRLF + "AND N3_CCD = ZZ0_EN_ATU "
  	CASE MV_PAR05 == "3"
  		cQuery += CRLF + "AND N3_ITEMD = ZZ0_EN_ATU "
  	CASE MV_PAR05 == "4"
  		cQuery += CRLF + "AND N3_CLVLDB = ZZ0_EN_ATU "
ENDCASE         
IF !EMPTY(MV_PAR02)
	cQuery += CRLF + "AND N3_CCD = '"+MV_PAR02+"' "
    ENDIF
IF !EMPTY(MV_PAR03)
	cQuery += CRLF + "AND N3_ITEMD = '"+MV_PAR03+"' "
    ENDIF
IF !EMPTY(MV_PAR04)
	cQuery += CRLF + "AND N3_CONTAD = '"+MV_PAR04+"' "
ENDIF	
FWrite(nHdl,cQuery + CHR(13)+CHR(10))
FWrite(nHdl," " + CHR(13)+CHR(10) )
TcSqlExec(cQuery)

cQuery := +;
"UPDATE "+RetSqlName("SN3")+" "
DO CASE
  	CASE MV_PAR05 == "1"
  		cQuery += CRLF + "SET N3_CONTAD = ZZ0_EN_NEW "
  	CASE MV_PAR05 == "2"
  		cQuery += CRLF + "SET N3_CCD = ZZ0_EN_NEW "
  	CASE MV_PAR05 == "3"
  		cQuery += CRLF + "SET N3_ITEMD = ZZ0_EN_NEW "
  	CASE MV_PAR05 == "4"
  		cQuery += CRLF + "SET N3_CLVLDB = ZZ0_EN_NEW "
ENDCASE
cQuery += CRLF +;  
"FROM "+RetSqlName("SN3")+ " SN3 WITH (NOLOCK),"+RetSqlName("ZZ0")+ " ZZ0 WITH (NOLOCK) " + CRLF +;
"WHERE SN3.D_E_L_E_T_ = ' ' " + CRLF +;
"AND ZZ0.D_E_L_E_T_ = ' ' " + CRLF +; 
"AND N3_SALDO > 0 " + CRLF +;
"AND YEAR(N3_AQUISIC) >= "+ALLTRIM(STR(VAL(MV_PAR01) - 1))+" " + CRLF +;
"AND ZZ0_EXERC = '"+MV_PAR01+"' " + CRLF +;
"AND ZZ0_ENTID = '"+MV_PAR05+"' " + CRLF +;
"AND ZZ0_PROCES = '1' "
DO CASE
  	CASE MV_PAR05 == "1"
  		cQuery += CRLF + "AND N3_CONTAD = ZZ0_EN_ATU "
  	CASE MV_PAR05 == "2"
  		cQuery += CRLF + "AND N3_CCD = ZZ0_EN_ATU "
  	CASE MV_PAR05 == "3"
  		cQuery += CRLF + "AND N3_ITEMD = ZZ0_EN_ATU "
  	CASE MV_PAR05 == "4"
  		cQuery += CRLF + "AND N3_CLVLDB = ZZ0_EN_ATU "
ENDCASE
IF !EMPTY(MV_PAR02)
	cQuery += CRLF + "AND N3_CCD = '"+MV_PAR02+"' "
    ENDIF
IF !EMPTY(MV_PAR03)
	cQuery += CRLF + "AND N3_ITEMD = '"+MV_PAR03+"' "
    ENDIF
IF !EMPTY(MV_PAR04)
	cQuery += CRLF + "AND N3_CONTAD = '"+MV_PAR04+"' "
ENDIF
FWrite(nHdl,cQuery + CHR(13)+CHR(10))
FWrite(nHdl," " + CHR(13)+CHR(10) )
TcSqlExec(cQuery)
*/

//ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
//บGrava flag de encerramento do cadastro de De/Para                 บ
//ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
cQuery := +;
"UPDATE "+RetSqlName("ZZ0")+" SET ZZ0_PROCES = '2' " + CRLF +;	
"WHERE D_E_L_E_T_ = ' ' " + CRLF +;
"AND ZZ0_FILIAL = '"+xFilial("ZZ0")+"' " + CRLF +;
"AND ZZ0_EXERC = '"+MV_PAR01+"' " + CRLF +;
"AND ZZ0_ENTID = '"+MV_PAR05+"' " + CRLF +;
"AND ZZ0_PROCES = '1' " 
FWrite(nHdl,"=========================================================================================================================================================================" + CHR(13)+CHR(10) )
FWrite(nHdl,cQuery + CHR(13)+CHR(10))
FWrite(nHdl," " + CHR(13)+CHR(10) )
TcSqlExec(cQuery)

lFim := .T.

End Transaction

If lFim
	FClose(nHdl)

	IF !ExistDir("C:\TEMP")
		IF MakeDir("C:\TEMP",NIL,.F.) != 0
			Return MsgStop('Erro ao tentar criar a pasta C:\TEMP no computador: ' + cValToChar(FError()) + '.', "SICTBA03")
		ENDIF
	ENDIF
		
	IF !CpyS2T(cArqName,"C:\TEMP") 
		MsgStop("Nใo foi possํvel copiar o arquivo de log para a seguinte pasta local do computador C:\TEMP.","SICTBA03")
	ENDIF
Endif

MsgAlert('Registros Alterados: ' + CRLF + CRLF + _MSG,'SICTBA03')

Return .T.

Static Function Proc_Perg()
/*/f/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
<Descricao> : Modulo de Contabilidade Gerencial. Processamento do De/Para das Entidades Contแbeis
<Autor> : Joao Carlos A. Neto
<Data> : 09/12/2013
<Parametros> :
<Retorno> : Nil
<Processo> : De/Para das entidades contแbeis
<Rotina> : Contabilidade
<Tipo> (Menu,Trigger,Validacao,Ponto de Entrada,Genericas,Especificas ) : P
<Obs> :
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/
Local aAreaAnt := GetArea()
Local aHelpPor := {}
Local aHelpEng := {}
Local aHelpSpa := {}
Local cPerg	   := "SICTBA03"

//---------------------------------------MV_PAR01--------------------------------------------------
aHelpPor := {"Ano do exercicio contแbil que se deseja","executar para que sejam efetuadas","as altera็๕es para o pr๓ximo Exercํcio"}
aHelpEng := {"Ano do exercicio contแbil que se deseja","executar para que sejam efetuadas","as altera็๕es para o pr๓ximo Exercํcio"}
aHelpSpa := {"Ano do exercicio contแbil que se deseja","executar para que sejam efetuadas","as altera็๕es para o pr๓ximo Exercํcio"}
PutSX1(cPerg,"01","Exercicio Contabil","Exercicio Contabil","Exercicio Contabil","mv_ch1","C",4,0,1,"G","","","","N","MV_PAR01","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

Pergunte(cPerg,.T.)

RestArea(aAreaAnt)

Return