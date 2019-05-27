#INCLUDE 'TOTVS.CH'

User Function MVCDBH()

Return

Static Function ModelDef
	
	Local oModel   := MpFormModel( 'DBH_MODEL' )
	Local oStrSM0  := GetSM0Str()
	Local oStrDBH := FWFormStruct( 1, 'DBH') 
	//Local oStrDBH2 := FWFormStruct( 1, 'DBH')

	oModel:SetDescription( 'Critério de Avaliação' )

	oModel:addFields( 'SM0-FILIAL',, oStrSM0,,, { |oFieldModel, lCopy| LoadSM0( oFieldModel, lCopy ) } )  
	oModel:getModel( 'SM0-FILIAL' ):SetDescription( 'Filial Corrente' )

	oModel:addGrid( 'DBH1', 'SM0-FILIAL', oStrDBH )
	oModel:getModel('DBH1'):SetDescription( 'Critério de Avaliação Solicitante' )
	oModel:SetRelation('DBH1', { { 'DBH_FILIAL', 'M0_CODFIL' } }, DBH->(IndexKey(1)) )
	oModel:GetModel( 'DBH1' ):SetLoadFilter( , "DBH_TIPO == '1' " )

	oModel:addGrid( 'DBH2', 'SM0-FILIAL', oStrDBH )
	oModel:getModel('DBH2'):SetDescription( 'Critério de Avaliação Comprador' )
	oModel:SetRelation('DBH2', { { 'DBH_FILIAL', 'M0_CODFIL' } }, DBH->(IndexKey(1)) )
	oModel:GetModel( 'DBH2' ):SetLoadFilter( , "DBH_TIPO == '2' " )

Return oModel

Static Function GetSM0Str()

	Local oStruct := FWFormModelStruct():New()

	oStruct:AddTable('SM0',{'M0_CODFIL'},'Filial')
	oStruct:AddField('Filial','Filial' , 'M0_CODFIL', 'C', 6, 0, , , {}, .F., , .F., .F., .F., , )
	oStruct:AddIndex( 1, 'FILIAL', 'M0_CODFIL', 'FILIAL', 'FILIAL', '', .F. )

return oStruct

Static Function LoadSM0(oFieldModel, lCopy, )

	Local aLoad := {}

	aAdd(aLoad, {FwxFilial('DBH')})
	aAdd(aLoad, 1)

Return aLoad