#include "protheus.ch"

User Function MVCDBH()
	
	Private cCadastro := "Cadastro de . . ."
	Private aRotina := { {"Pesquisar","AxPesqui",0,1} ,;
		{"Visualizar","u_mgetdb",0,2} ,;
		{"Incluir","u_mgetdb",0,3} ,;
		{"Alterar","u_mgetdb",0,4} ,;
		{"Excluir","u_mgetdb",0,5} }
	Private cString := "DBH"
	dbSelectArea(cString)
	dbSetOrder(1)
	
	mBrowse( 6,1,22,75,cString)
	
return

user function mgetdb(calias,nrec,nopc)
	
	Local aStruct := {}
	Local x,odlg,ogetdb
	Local nUsado := 0
	Local aAlter := {}
	Local oSize  := FwDefSize():New(.T.)
	
	
	private aheader := {}
	private aaltera := {}
	
	oSize:AddObject( "LISTA", 000, 000, .T., .T. )
	
	oSize:Process()
	
	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek("DBH")
	
	While !Eof() .and. SX3->X3_ARQUIVO == "DBH"
		
		If X3Uso(SX3->X3_USADO) .and. cNivel >= SX3->X3_NIVEL
			
			nUsado++
			
			Aadd(aHeader,{Trim(X3Titulo()),;
				SX3->X3_CAMPO,;
				SX3->X3_PICTURE,;
				SX3->X3_TAMANHO,;
				SX3->X3_DECIMAL,;
				SX3->X3_VALID,;
				"",;
				SX3->X3_TIPO,;
				"",;
				"" })
			
			Aadd(aStruct,{SX3->X3_CAMPO,;
				SX3->X3_TIPO,;
				SX3->X3_TAMANHO,;
				SX3->X3_DECIMAL})
			
			aAdd( aAlter, SX3->X3_CAMPO )
		EndIf
		
		DbSkip()
	End
	Aadd(aStruct,{"FLAG","L",1,0})
	
	cCriaTrab := CriaTrab(aStruct,.T.)
	
	DbUseArea(.T.,__LocalDriver,cCriaTrab,,.T.,.F.)
	
	DEFINE MSDIALOG oDlg TITLE "Documentação - MsGetDb" FROM ;
		oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] PIXEL
	
	//oGetDB := MsGetDB():New(006, 006, 232, 243, 3, "U_XLINHAOK", "U_XTUDOOK", "+A1_COD", .T., aAlter/*{"B1_DESC"}*/, , .F., , cCriaTrab, "U_XFIELDOK", , .T., oDlg, .T., ,"U_XDELOK", "U_XSUPERDEL")
	oGetDB := MsGetDB():New(;
		oSize:GetDimension("LISTA","LININI"), oSize:GetDimension("LISTA","COLINI"), ;
		oSize:GetDimension("LISTA","LINEND"), oSize:GetDimension("LISTA","COLEND"), ;
		3, "U_XLINHAOK", "U_XTUDOOK", "+A1_COD", .T., aAlter/*{"B1_DESC"}*/, , .F., , cCriaTrab, "U_XFIELDOK", , .T., oDlg, .T., ,"U_XDELOK", "U_XSUPERDEL")
	
	
	EnchoiceBar( oDlg, {||Nil}, {||oDlg:End()},,,,,.F.,.F.,.F.,.F.,.F. )
	
	ACTIVATE MSDIALOG oDlg CENTERED
	
	DbSelectArea(cCriaTrab)
	DbCloseArea()
	
return

User Function XLINHAOK()
	
	ApMsgStop("LINHAOK")
	
Return .T.

User Function XTUDOOK()
	
	ApMsgStop("LINHAOK")
	
Return .T.

User Function XDELOK()
	
	ApMsgStop("DELOK")
	
Return .T.

User Function XSUPERDEL()
	
	ApMsgStop("SUPERDEL")
	
Return .T.

User Function XFIELDOK()
	
	ApMsgStop("FIELDOK")
	
Return .T.


User Function Teste()
	
Return
