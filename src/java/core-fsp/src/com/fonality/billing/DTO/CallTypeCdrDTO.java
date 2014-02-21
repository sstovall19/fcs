package com.fonality.billing.DTO;

import java.io.Serializable;
import java.math.BigDecimal;

import com.fonality.util.FSPConstants;

public class CallTypeCdrDTO implements Serializable {

	private static final long serialVersionUID = 6090971391708806794L;
	private String callType;
	private BigDecimal billedAmount;
	private Integer durationSum;

	/**
	 * @param callType
	 */
	public CallTypeCdrDTO(String callType) {
		super();
		this.callType = callType;
	}

	/**
	 * @param callType
	 * @param billedAmount
	 * @param durationSum
	 */
	public CallTypeCdrDTO(String callType, BigDecimal billedAmount, Integer durationSum) {
		super();
		this.callType = callType;
		this.billedAmount = billedAmount;
		this.durationSum = durationSum;
	}

	/**
	 * @return the callType
	 */
	public String getCallType() {
		return callType;
	}

	/**
	 * @param callType
	 *            the callType to set
	 */
	public void setCallType(String callType) {
		this.callType = callType;
	}

	/**
	 * @return the billedAmount
	 */
	public BigDecimal getBilledAmount() {
		return billedAmount;
	}

	/**
	 * @param billedAmount
	 *            the billedAmount to set
	 */
	public void setBilledAmount(BigDecimal billedAmount) {
		this.billedAmount = billedAmount;
	}

	/**
	 * @return the durationSum
	 */
	public Integer getDurationSum() {
		return durationSum;
	}

	/**
	 * @param durationSum
	 *            the durationSum to set
	 */
	public void setDurationSum(Integer durationSum) {
		this.durationSum = durationSum;
	}

	/*
	 * (non-Javadoc)
	 * @see java.lang.Object#hashCode()
	 */
	@Override
	public int hashCode() {
		final int prime = FSPConstants.HASHCODE_PRIME;
		int result = 1;
		result = prime * result + ((callType == null) ? 0 : callType.hashCode());
		return result;
	}

	/*
	 * (non-Javadoc)
	 * @see java.lang.Object#equals(java.lang.Object)
	 */
	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
		CallTypeCdrDTO other = (CallTypeCdrDTO) obj;
		if (callType == null) {
			if (other.callType != null)
				return false;
		} else if (!callType.equals(other.callType))
			return false;
		return true;
	}

	/*
	 * (non-Javadoc)
	 * @see java.lang.Object#toString()
	 */
	@Override
	public String toString() {
		return "CallTypeCdrDTO [callType=" + callType + ", billedAmount=" + billedAmount
				+ ", durationSum=" + durationSum + "]";
	}

}
