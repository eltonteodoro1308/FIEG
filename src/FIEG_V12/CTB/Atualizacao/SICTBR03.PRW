#INCLUDE "PROTHEUS.CH"    

// Autor....: Thiago Rasmussen
// Data.....: 08/01/2016
// Modulo...: 34 - Contábil
// Descrição: Gerar relatório de log do processo de DE/PARA.

User Function SICTBR03()

Local oExcel := FWMSEXCEL():New()
Local _SQL   := ""                                 
Local _ALIAS := GetNextAlias()
Local _FILE  := DTOS(DATE()) + " - " + SUBSTR(TIME(),1,2) + "_" + SUBSTR(TIME(),4,2) + "_" + SUBSTR(TIME(),7,2)
Local _ZZ0_FILIAL := ZZ0->ZZ0_FILIAL
Local _ZZ0_EXERC  := ZZ0->ZZ0_EXERC
Local _ZZ0_ENTID  := ZZ0->ZZ0_ENTID
Local _ZZ0_EN_ATU := ZZ0->ZZ0_EN_ATU
Local _ZZ0_EN_NEW := ZZ0->ZZ0_EN_NEW
Local _ZZ0_DATHOR := ZZ0->ZZ0_DATHOR

oExcel:AddworkSheet("DE/PARA")
oExcel:AddTable ("DE/PARA","DE/PARA")
oExcel:AddColumn("DE/PARA","DE/PARA","Filial",1,1)
oExcel:AddColumn("DE/PARA","DE/PARA","Exercício",1,1)
oExcel:AddColumn("DE/PARA","DE/PARA","Entidade",1,1)
oExcel:AddColumn("DE/PARA","DE/PARA","Entidade Original",1,1)
oExcel:AddColumn("DE/PARA","DE/PARA","Entidade Nova",1,1)
oExcel:AddColumn("DE/PARA","DE/PARA","Data/Hora",1,1)
oExcel:AddRow("DE/PARA","DE/PARA",{_ZZ0_FILIAL, _ZZ0_EXERC, _ZZ0_ENTID, _ZZ0_EN_ATU, _ZZ0_EN_NEW, _ZZ0_DATHOR})

//*********************************************************************************************************************************************************************
// Solicitação de Compra
_SQL := +;
"SELECT " + CRLF +;
"C1_FILIAL, " + CRLF +;
"C1_NUM, " + CRLF +;
"C1_ITEM, " + CRLF +;
"CONVERT(VARCHAR(10), CAST(C1_EMISSAO AS DATE), 103) AS C1_EMISSAO " + CRLF +;
"FROM SC1010 WITH (NOLOCK) " + CRLF +;
"WHERE R_E_C_N_O_ IN (SELECT ZZ1_RECNO FROM ZZ1010 WITH (NOLOCK) " + CRLF +;
"                     WHERE ZZ1_FILIAL = '" + _ZZ0_FILIAL + "' AND " + CRLF +;
"                           ZZ1_EXERC = '" + _ZZ0_EXERC + "' AND " + CRLF +;
"                           ZZ1_ENTID = '" + _ZZ0_ENTID + "' AND " + CRLF +;
"                           ZZ1_EN_ATU = '" + _ZZ0_EN_ATU + "' AND " + CRLF +;
"                           ZZ1_EN_NEW = '" + _ZZ0_EN_NEW + "' AND " + CRLF +;
"                           ZZ1_DATHOR = '" + _ZZ0_DATHOR + "' AND " + CRLF +;
"                           ZZ1_TABELA = 'SC1' AND " + CRLF +;
"                           D_E_L_E_T_ = '') " + CRLF +;
"ORDER BY 1,2,3"

IF SELECT(_ALIAS) > 0
	dbSelectArea(_ALIAS)
	dbCloseArea()
ENDIF
   
MsAguarde({|| dbUseArea(.T.,"TOPCONN",TcGenQry(,,_SQL),_ALIAS,.T.,.F.)},"Selecionando registros SC...")
Count to nCount  

DbSelectArea(_ALIAS)
dbGotop()

IF nCount > 0
	oExcel:AddworkSheet("SC")
	oExcel:AddTable ("SC","Solicitação de Compra")
	oExcel:AddColumn("SC","Solicitação de Compra","Filial",1,1)
	oExcel:AddColumn("SC","Solicitação de Compra","Número",1,1)
	oExcel:AddColumn("SC","Solicitação de Compra","Item",1,1)
	oExcel:AddColumn("SC","Solicitação de Compra","Data de Emissão",1,4)

	WHILE !(_ALIAS)->(EOF())     
		oExcel:AddRow("SC","Solicitação de Compra",{(_ALIAS)->C1_FILIAL,(_ALIAS)->C1_NUM,(_ALIAS)->C1_ITEM,(_ALIAS)->C1_EMISSAO})

		(_ALIAS)->(dbSkip())
	END	
ENDIF
	                                                                                                                                
(_ALIAS)->(dbCloseArea())    

//*********************************************************************************************************************************************************************
// Pedido de Compra
_SQL := +;
"SELECT " + CRLF +;
"C7_FILIAL, " + CRLF +;
"C7_NUM, " + CRLF +;
"C7_ITEM, " + CRLF +;
"CONVERT(VARCHAR(10), CAST(C7_EMISSAO AS DATE), 103) AS C7_EMISSAO " + CRLF +;
"FROM SC7010 WITH (NOLOCK) " + CRLF +;
"WHERE R_E_C_N_O_ IN (SELECT ZZ1_RECNO FROM ZZ1010 WITH (NOLOCK) " + CRLF +;
"                     WHERE ZZ1_FILIAL = '" + _ZZ0_FILIAL + "' AND " + CRLF +;
"                           ZZ1_EXERC = '" + _ZZ0_EXERC + "' AND " + CRLF +;
"                           ZZ1_ENTID = '" + _ZZ0_ENTID + "' AND " + CRLF +;
"                           ZZ1_EN_ATU = '" + _ZZ0_EN_ATU + "' AND " + CRLF +;
"                           ZZ1_EN_NEW = '" + _ZZ0_EN_NEW + "' AND " + CRLF +;
"                           ZZ1_DATHOR = '" + _ZZ0_DATHOR + "' AND " + CRLF +;
"                           ZZ1_TABELA = 'SC7' AND " + CRLF +;
"                           D_E_L_E_T_ = '') " + CRLF +;
"ORDER BY 1,2,3"

IF SELECT(_ALIAS) > 0
	dbSelectArea(_ALIAS)
	dbCloseArea()
ENDIF
   
MsAguarde({|| dbUseArea(.T.,"TOPCONN",TcGenQry(,,_SQL),_ALIAS,.T.,.F.)},"Selecionando registros PC...")
Count to nCount  

DbSelectArea(_ALIAS)
dbGotop()

IF nCount > 0
	oExcel:AddworkSheet("PC")
	oExcel:AddTable ("PC","Pedido de Compra")
	oExcel:AddColumn("PC","Pedido de Compra","Filial",1,1)
	oExcel:AddColumn("PC","Pedido de Compra","Número",1,1)
	oExcel:AddColumn("PC","Pedido de Compra","Item",1,1)
	oExcel:AddColumn("PC","Pedido de Compra","Data de Emissão",1,4)
	                                                                                                                                
	While !(_ALIAS)->(EOF())     
		oExcel:AddRow("PC","Pedido de Compra",{(_ALIAS)->C7_FILIAL,(_ALIAS)->C7_NUM,(_ALIAS)->C7_ITEM,(_ALIAS)->C7_EMISSAO})
	
		(_ALIAS)->(dbSkip())
	END
ENDIF
	
(_ALIAS)->(dbCloseArea())    

//*********************************************************************************************************************************************************************
// Nota Fiscal de Entrada
_SQL := +;
"SELECT " + CRLF +;
"D1_FILIAL, " + CRLF +;
"D1_DOC, " + CRLF +;
"D1_SERIE, " + CRLF +;
"RTRIM(D1_FORNECE) + ' - ' + A2_NOME AS D1_FORNECE, " + CRLF +;
"D1_ITEM, " + CRLF +;
"CONVERT(VARCHAR(10), CAST(D1_EMISSAO AS DATE), 103) AS D1_EMISSAO " + CRLF +;
"FROM SD1010 WITH (NOLOCK) " + CRLF +;
"LEFT JOIN SA2010 WITH (NOLOCK) ON A2_FILIAL = '' AND " + CRLF +;
"                                  A2_COD = D1_FORNECE AND " + CRLF +;
"                                  A2_LOJA = D1_LOJA AND " + CRLF +;
"                                  SA2010.D_E_L_E_T_ = '' " + CRLF +;
"WHERE SD1010.R_E_C_N_O_ IN (SELECT ZZ1_RECNO FROM ZZ1010 WITH (NOLOCK) " + CRLF +;
"                            WHERE ZZ1_FILIAL = '" + _ZZ0_FILIAL + "' AND " + CRLF +;
"                                  ZZ1_EXERC = '" + _ZZ0_EXERC + "' AND " + CRLF +;
"                                  ZZ1_ENTID = '" + _ZZ0_ENTID + "' AND " + CRLF +;
"                                  ZZ1_EN_ATU = '" + _ZZ0_EN_ATU + "' AND " + CRLF +;
"                                  ZZ1_EN_NEW = '" + _ZZ0_EN_NEW + "' AND " + CRLF +;
"                                  ZZ1_DATHOR = '" + _ZZ0_DATHOR + "' AND " + CRLF +;
"                                  ZZ1_TABELA = 'SD1' AND " + CRLF +;
"                                  D_E_L_E_T_ = '') " + CRLF +;
"ORDER BY 1,2,3,4,5"

IF SELECT(_ALIAS) > 0
	dbSelectArea(_ALIAS)
	dbCloseArea()
ENDIF
   
MsAguarde({|| dbUseArea(.T.,"TOPCONN",TcGenQry(,,_SQL),_ALIAS,.T.,.F.)},"Selecionando registros NF...")
Count to nCount  

DbSelectArea(_ALIAS)
dbGotop()

IF nCount > 0
	oExcel:AddworkSheet("NF")
	oExcel:AddTable ("NF","NF de Entrada")
	oExcel:AddColumn("NF","NF de Entrada","Filial",1,1)
	oExcel:AddColumn("NF","NF de Entrada","Número",1,1)
	oExcel:AddColumn("NF","NF de Entrada","Série",1,1)
	oExcel:AddColumn("NF","NF de Entrada","Fornecedor",1,1)
	oExcel:AddColumn("NF","NF de Entrada","Item",1,1)
	oExcel:AddColumn("NF","NF de Entrada","Data de Emissão",1,4)
	                                                                                                                                
	While !(_ALIAS)->(EOF())     
		oExcel:AddRow("NF","NF de Entrada",{(_ALIAS)->D1_FILIAL,(_ALIAS)->D1_DOC,(_ALIAS)->D1_SERIE,(_ALIAS)->D1_FORNECE,(_ALIAS)->D1_ITEM,(_ALIAS)->D1_EMISSAO})
	
		(_ALIAS)->(dbSkip())
	END
ENDIF
	
(_ALIAS)->(dbCloseArea())    

//*********************************************************************************************************************************************************************
// Contrato
_SQL := +;
"SELECT " + CRLF +;
"CNB_FILIAL, " + CRLF +;
"CNB_CONTRA, " + CRLF +;
"CNB_REVISA, " + CRLF +;
"CNB_ITEM, " + CRLF +;
"CONVERT(VARCHAR(10), CAST(CN9_DTINIC AS DATE), 103) AS CN9_DTINIC " + CRLF +;
"FROM CNB010 WITH (NOLOCK) " + CRLF +;
"INNER JOIN CN9010 WITH (NOLOCK) ON CN9_FILIAL = CNB_FILIAL AND " + CRLF +;
"                                   CN9_NUMERO = CNB_CONTRA AND " + CRLF +;
"                                   CN9_REVISA = CNB_REVISA " + CRLF +;
"WHERE CNB010.R_E_C_N_O_ IN (SELECT ZZ1_RECNO FROM ZZ1010 WITH (NOLOCK) " + CRLF +;
"                            WHERE ZZ1_FILIAL = '" + _ZZ0_FILIAL + "' AND " + CRLF +;
"                                  ZZ1_EXERC = '" + _ZZ0_EXERC + "' AND " + CRLF +;
"                                  ZZ1_ENTID = '" + _ZZ0_ENTID + "' AND " + CRLF +;
"                                  ZZ1_EN_ATU = '" + _ZZ0_EN_ATU + "' AND " + CRLF +;
"                                  ZZ1_EN_NEW = '" + _ZZ0_EN_NEW + "' AND " + CRLF +;
"                                  ZZ1_DATHOR = '" + _ZZ0_DATHOR + "' AND " + CRLF +;
"                                  ZZ1_TABELA = 'CNB' AND " + CRLF +;
"                                  D_E_L_E_T_ = '') " + CRLF +;
"ORDER BY 1,2,3,4"

IF SELECT(_ALIAS) > 0
	dbSelectArea(_ALIAS)
	dbCloseArea()
ENDIF
   
MsAguarde({|| dbUseArea(.T.,"TOPCONN",TcGenQry(,,_SQL),_ALIAS,.T.,.F.)},"Selecionando registros Contrato...")
Count to nCount  

DbSelectArea(_ALIAS)
dbGotop()

IF nCount > 0
	oExcel:AddworkSheet("Contrato")
	oExcel:AddTable ("Contrato","Contrato")
	oExcel:AddColumn("Contrato","Contrato","Filial",1,1)
	oExcel:AddColumn("Contrato","Contrato","Número",1,1)
	oExcel:AddColumn("Contrato","Contrato","Revisão",1,1)
	oExcel:AddColumn("Contrato","Contrato","Item",1,1)
	oExcel:AddColumn("Contrato","Contrato","Data Inicial",1,4)
	                                                                                                                                
	While !(_ALIAS)->(EOF())     
		oExcel:AddRow("Contrato","Contrato",{(_ALIAS)->CNB_FILIAL,(_ALIAS)->CNB_CONTRA,(_ALIAS)->CNB_REVISA,(_ALIAS)->CNB_ITEM,(_ALIAS)->CN9_DTINIC})
	
		(_ALIAS)->(dbSkip())
	END
ENDIF
	
(_ALIAS)->(dbCloseArea())    

//*********************************************************************************************************************************************************************
// Medição
_SQL := +;
"SELECT " + CRLF +;
"CNE_FILIAL, " + CRLF +;
"CNE_CONTRA, " + CRLF +;
"CNE_REVISA, " + CRLF +;
"CNE_NUMMED, " + CRLF +;
"CNE_ITEM, " + CRLF +;
"CONVERT(VARCHAR(10), CAST(CNE_DTENT AS DATE), 103) AS CNE_DTENT " + CRLF +;
"FROM CNE010 WITH (NOLOCK) " + CRLF +;
"WHERE R_E_C_N_O_ IN (SELECT ZZ1_RECNO FROM ZZ1010 WITH (NOLOCK) " + CRLF +;
"                     WHERE ZZ1_FILIAL = '" + _ZZ0_FILIAL + "' AND " + CRLF +;
"                           ZZ1_EXERC = '" + _ZZ0_EXERC + "' AND " + CRLF +;
"                           ZZ1_ENTID = '" + _ZZ0_ENTID + "' AND " + CRLF +;
"                           ZZ1_EN_ATU = '" + _ZZ0_EN_ATU + "' AND " + CRLF +;
"                           ZZ1_EN_NEW = '" + _ZZ0_EN_NEW + "' AND " + CRLF +;
"                           ZZ1_DATHOR = '" + _ZZ0_DATHOR + "' AND " + CRLF +;
"                           ZZ1_TABELA = 'CNE' AND " + CRLF +;
"                           D_E_L_E_T_ = '') " + CRLF +;
"ORDER BY 1,2,3,4"

IF SELECT(_ALIAS) > 0
	dbSelectArea(_ALIAS)
	dbCloseArea()
ENDIF
   
MsAguarde({|| dbUseArea(.T.,"TOPCONN",TcGenQry(,,_SQL),_ALIAS,.T.,.F.)},"Selecionando registros Medição...")
Count to nCount  

DbSelectArea(_ALIAS)
dbGotop()

IF nCount > 0
	oExcel:AddworkSheet("Medição")
	oExcel:AddTable ("Medição","Medição")
	oExcel:AddColumn("Medição","Medição","Filial",1,1)
	oExcel:AddColumn("Medição","Medição","Contrato",1,1)
	oExcel:AddColumn("Medição","Medição","Revisão",1,1)
	oExcel:AddColumn("Medição","Medição","Medição",1,1)
	oExcel:AddColumn("Medição","Medição","Item",1,1)
	oExcel:AddColumn("Medição","Medição","Data de Entrada",1,4)
	                                                                                                                                
	While !(_ALIAS)->(EOF())     
		oExcel:AddRow("Medição","Medição",{(_ALIAS)->CNE_FILIAL,(_ALIAS)->CNE_CONTRA,(_ALIAS)->CNE_REVISA,(_ALIAS)->CNE_NUMMED,(_ALIAS)->CNE_ITEM,(_ALIAS)->CNE_DTENT})
	
		(_ALIAS)->(dbSkip())
	END
ENDIF
	
(_ALIAS)->(dbCloseArea())    

//*********************************************************************************************************************************************************************
// Cadastro de Bancos
_SQL := +;
"SELECT " + CRLF +;
"A6_FILIAL, " + CRLF +;
"A6_COD, " + CRLF +;
"A6_AGENCIA, " + CRLF +;
"A6_NUMCON, " + CRLF +;
"A6_NOME " + CRLF +;
"FROM SA6010 WITH (NOLOCK) " + CRLF +;
"WHERE R_E_C_N_O_ IN (SELECT ZZ1_RECNO FROM ZZ1010 WITH (NOLOCK) " + CRLF +;
"                     WHERE ZZ1_FILIAL = '" + _ZZ0_FILIAL + "' AND " + CRLF +;
"                           ZZ1_EXERC = '" + _ZZ0_EXERC + "' AND " + CRLF +;
"                           ZZ1_ENTID = '" + _ZZ0_ENTID + "' AND " + CRLF +;
"                           ZZ1_EN_ATU = '" + _ZZ0_EN_ATU + "' AND " + CRLF +;
"                           ZZ1_EN_NEW = '" + _ZZ0_EN_NEW + "' AND " + CRLF +;
"                           ZZ1_DATHOR = '" + _ZZ0_DATHOR + "' AND " + CRLF +;
"                           ZZ1_TABELA = 'SA6' AND " + CRLF +;
"                           D_E_L_E_T_ = '') " + CRLF +;
"ORDER BY 1,2,3,4"

IF SELECT(_ALIAS) > 0
	dbSelectArea(_ALIAS)
	dbCloseArea()
ENDIF
   
MsAguarde({|| dbUseArea(.T.,"TOPCONN",TcGenQry(,,_SQL),_ALIAS,.T.,.F.)},"Selecionando registros Banco...")
Count to nCount  

DbSelectArea(_ALIAS)
dbGotop()

IF nCount > 0
	oExcel:AddworkSheet("Banco")
	oExcel:AddTable ("Banco","Banco")
	oExcel:AddColumn("Banco","Banco","Filial",1,1)
	oExcel:AddColumn("Banco","Banco","Banco",1,1)
	oExcel:AddColumn("Banco","Banco","Agencia",1,1)
	oExcel:AddColumn("Banco","Banco","Conta",1,1)
	oExcel:AddColumn("Banco","Banco","Descrição",1,1)
	                                                                                                                                
	While !(_ALIAS)->(EOF())     
		oExcel:AddRow("Banco","Banco",{(_ALIAS)->A6_FILIAL,(_ALIAS)->A6_COD,(_ALIAS)->A6_AGENCIA,(_ALIAS)->A6_NUMCON,(_ALIAS)->A6_NOME})
	
		(_ALIAS)->(dbSkip())
	END
ENDIF
	
(_ALIAS)->(dbCloseArea())    

//*********************************************************************************************************************************************************************
// Contas a Receber
_SQL := +;
"SELECT " + CRLF +;
"E1_FILIAL, " + CRLF +;
"E1_PREFIXO, " + CRLF +;
"E1_NUM, " + CRLF +;
"E1_PARCELA, " + CRLF +;
"E1_TIPO, " + CRLF +;
"E1_CLIENTE + ' - ' + A1_NOME AS E1_CLIENTE, " + CRLF +;
"CONVERT(VARCHAR(10), CAST(E1_EMISSAO AS DATE), 103) AS E1_EMISSAO " + CRLF +;
"FROM SE1010 WITH (NOLOCK) " + CRLF +;
"LEFT JOIN SA1010 WITH (NOLOCK) ON A1_FILIAL = '' AND " + CRLF +;
"                                  A1_COD = E1_CLIENTE AND " + CRLF +;
"                                  A1_LOJA = E1_LOJA AND " + CRLF +;
"                                  SA1010.D_E_L_E_T_ = '' " + CRLF +;
"WHERE SE1010.R_E_C_N_O_ IN (SELECT ZZ1_RECNO FROM ZZ1010 WITH (NOLOCK) " + CRLF +;
"                            WHERE ZZ1_FILIAL = '" + _ZZ0_FILIAL + "' AND " + CRLF +;
"                                  ZZ1_EXERC = '" + _ZZ0_EXERC + "' AND " + CRLF +;
"                                  ZZ1_ENTID = '" + _ZZ0_ENTID + "' AND " + CRLF +;
"                                  ZZ1_EN_ATU = '" + _ZZ0_EN_ATU + "' AND " + CRLF +;
"                                  ZZ1_EN_NEW = '" + _ZZ0_EN_NEW + "' AND " + CRLF +;
"                                  ZZ1_DATHOR = '" + _ZZ0_DATHOR + "' AND " + CRLF +;
"                                  ZZ1_TABELA = 'SE1' AND " + CRLF +;
"                                  D_E_L_E_T_ = '') " + CRLF +;
"ORDER BY 1,2,3,4"

IF SELECT(_ALIAS) > 0
	dbSelectArea(_ALIAS)
	dbCloseArea()
ENDIF
   
MsAguarde({|| dbUseArea(.T.,"TOPCONN",TcGenQry(,,_SQL),_ALIAS,.T.,.F.)},"Selecionando registros CR...")
Count to nCount  

DbSelectArea(_ALIAS)
dbGotop()

IF nCount > 0
	oExcel:AddworkSheet("CR")
	oExcel:AddTable ("CR","Contas a Receber")
	oExcel:AddColumn("CR","Contas a Receber","Filial",1,1)
	oExcel:AddColumn("CR","Contas a Receber","Prefixo",1,1)
	oExcel:AddColumn("CR","Contas a Receber","Número",1,1)
	oExcel:AddColumn("CR","Contas a Receber","Parcela",1,1)
	oExcel:AddColumn("CR","Contas a Receber","Tipo",1,1)
	oExcel:AddColumn("CR","Contas a Receber","Cliente",1,1)
	oExcel:AddColumn("CR","Contas a Receber","Data de Emissão",1,4)
	                                                                                                                                
	While !(_ALIAS)->(EOF())     
		oExcel:AddRow("CR","Contas a Receber",{(_ALIAS)->E1_FILIAL,(_ALIAS)->E1_PREFIXO,(_ALIAS)->E1_NUM,(_ALIAS)->E1_PARCELA,(_ALIAS)->E1_TIPO,(_ALIAS)->E1_CLIENTE,(_ALIAS)->E1_EMISSAO})
	
		(_ALIAS)->(dbSkip())
	END
ENDIF
	
(_ALIAS)->(dbCloseArea())    

//*********************************************************************************************************************************************************************
// Contas a Pagar
_SQL := +;
"SELECT " + CRLF +;
"E2_FILIAL, " + CRLF +;
"E2_PREFIXO, " + CRLF +;
"E2_NUM, " + CRLF +;
"E2_PARCELA, " + CRLF +;
"E2_TIPO, " + CRLF +;
"E2_FORNECE + ' - ' + A2_NOME AS E2_FORNECE, " + CRLF +;
"CONVERT(VARCHAR(10), CAST(E2_EMISSAO AS DATE), 103) AS E2_EMISSAO " + CRLF +;
"FROM SE2010 WITH (NOLOCK) " + CRLF +;
"LEFT JOIN SA2010 WITH (NOLOCK) ON A2_FILIAL = '' AND " + CRLF +; 
"                                  A2_COD = E2_FORNECE AND " + CRLF +;
"                                  A2_LOJA = E2_LOJA AND " + CRLF +;
"                                  SA2010.D_E_L_E_T_ = '' " + CRLF +;
"WHERE SE2010.R_E_C_N_O_ IN (SELECT ZZ1_RECNO FROM ZZ1010 WITH (NOLOCK) " + CRLF +;
"                            WHERE ZZ1_FILIAL = '" + _ZZ0_FILIAL + "' AND " + CRLF +;
"                                  ZZ1_EXERC = '" + _ZZ0_EXERC + "' AND " + CRLF +;
"                                  ZZ1_ENTID = '" + _ZZ0_ENTID + "' AND " + CRLF +;
"                                  ZZ1_EN_ATU = '" + _ZZ0_EN_ATU + "' AND " + CRLF +;
"                                  ZZ1_EN_NEW = '" + _ZZ0_EN_NEW + "' AND " + CRLF +;
"                                  ZZ1_DATHOR = '" + _ZZ0_DATHOR + "' AND " + CRLF +;
"                                  ZZ1_TABELA = 'SE2' AND " + CRLF +;
"                                  D_E_L_E_T_ = '') " + CRLF +;
"ORDER BY 1,2,3,4"

IF SELECT(_ALIAS) > 0
	dbSelectArea(_ALIAS)
	dbCloseArea()
ENDIF
   
MsAguarde({|| dbUseArea(.T.,"TOPCONN",TcGenQry(,,_SQL),_ALIAS,.T.,.F.)},"Selecionando registros CP...")
Count to nCount  

DbSelectArea(_ALIAS)
dbGotop()

IF nCount > 0
	oExcel:AddworkSheet("CP")
	oExcel:AddTable ("CP","Contas a Pagar")
	oExcel:AddColumn("CP","Contas a Pagar","Filial",1,1)
	oExcel:AddColumn("CP","Contas a Pagar","Prefixo",1,1)
	oExcel:AddColumn("CP","Contas a Pagar","Número",1,1)
	oExcel:AddColumn("CP","Contas a Pagar","Parcela",1,1)
	oExcel:AddColumn("CP","Contas a Pagar","Tipo",1,1)
	oExcel:AddColumn("CP","Contas a Pagar","Fornecedor",1,1)
	oExcel:AddColumn("CP","Contas a Pagar","Data de Emissão",1,4)
	                                                                                                                                
	While !(_ALIAS)->(EOF())     
		oExcel:AddRow("CP","Contas a Pagar",{(_ALIAS)->E2_FILIAL,(_ALIAS)->E2_PREFIXO,(_ALIAS)->E2_NUM,(_ALIAS)->E2_PARCELA,(_ALIAS)->E2_TIPO,(_ALIAS)->E2_FORNECE,(_ALIAS)->E2_EMISSAO})
	
		(_ALIAS)->(dbSkip())
	END
ENDIF
	
(_ALIAS)->(dbCloseArea())    


oExcel:Activate()
//oExcel:GetXMLFile("C:\TESTE.xml")

LjMsgRun( "Gerando o arquivo, aguarde...", "Exportando os Registros para o Excel", {|| oExcel:GetXMLFile("C:\TEMP\LOG_DE_PARA - " + _FILE + ".XML") } )

oExcelApp := MsExcel():New()
oExcelApp:WorkBooks:Open("C:\TEMP\LOG_DE_PARA - " + _FILE + ".XML")
oExcelApp:SetVisible(.T.)    
oExcelApp:Destroy()

Return