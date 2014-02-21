package com.fonality.dao;

import java.util.List;

import com.fonality.bu.entity.TaxMapping;

public interface TaxMappingDAO {

    
    /**
     * Method to load tax mapping by tax mapping id
     * 
     * @return the tax mapping
     */
    public TaxMapping loadTaxMapping(int taxMappingId);
    
    public Integer getBSTransTypeForId(int taxMappingId);
    
    public Integer getBSServiceTypeForId(int taxMappingId);

}
