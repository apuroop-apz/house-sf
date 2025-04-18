//**********************************************************************************************************************
// Interface containing methods Trigger Handlers must implement to enforce best practice and bulkification of triggers.
// Original author: Tony Scott
// Implemented by: Apuroop
//  
// Reference:
// https://meltedwires.com/2013/06/05/trigger-pattern-for-tidy-streamlined-bulkified-triggers-revisited/
//**********************************************************************************************************************
public interface ITrigger
{
    void bulkBefore();
    void bulkAfter();
    void beforeInsert(SObject so);
    void beforeUpdate(SObject oldSo, SObject so);
    void beforeDelete(SObject so);
    void afterInsert(SObject so);
    void afterUpdate(SObject oldSo, SObject so);
    void afterDelete(SObject so);
    void andFinally();
}