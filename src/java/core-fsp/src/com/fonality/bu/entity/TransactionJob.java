package com.fonality.bu.entity;

// Generated Mar 21, 2013 12:26:07 PM by Hibernate Tools 3.4.0.CR1

import java.util.Date;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import static javax.persistence.GenerationType.IDENTITY;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;

/**
 * TransactionJob generated by hbm2java
 */
@Entity
@Table(name = "transaction_job", catalog = "fcs")
public class TransactionJob implements java.io.Serializable {

	private Integer transactionJobId;
	private TransactionStep transactionStep;
	private TransactionSubmit transactionSubmit;
	private String sequenceName;
	private byte iterations;
	private byte rollbackIterations;
	private byte[] input;
	private byte[] output;
	private byte[] rollbackOutput;
	private byte[] error;
	private byte[] rollbackError;
	private String status;
	private int executionTime;
	private Date created;
	private Date updated;

	public TransactionJob() {
	}

	public TransactionJob(TransactionStep transactionStep,
			TransactionSubmit transactionSubmit, String sequenceName,
			byte iterations, byte rollbackIterations, byte[] input,
			byte[] output, byte[] rollbackOutput, byte[] error,
			byte[] rollbackError, String status, int executionTime,
			Date created, Date updated) {
		this.transactionStep = transactionStep;
		this.transactionSubmit = transactionSubmit;
		this.sequenceName = sequenceName;
		this.iterations = iterations;
		this.rollbackIterations = rollbackIterations;
		this.input = input;
		this.output = output;
		this.rollbackOutput = rollbackOutput;
		this.error = error;
		this.rollbackError = rollbackError;
		this.status = status;
		this.executionTime = executionTime;
		this.created = created;
		this.updated = updated;
	}

	@Id
	@GeneratedValue(strategy = IDENTITY)
	@Column(name = "transaction_job_id", unique = true, nullable = false)
	public Integer getTransactionJobId() {
		return this.transactionJobId;
	}

	public void setTransactionJobId(Integer transactionJobId) {
		this.transactionJobId = transactionJobId;
	}

	@ManyToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "transaction_step_id", nullable = false)
	public TransactionStep getTransactionStep() {
		return this.transactionStep;
	}

	public void setTransactionStep(TransactionStep transactionStep) {
		this.transactionStep = transactionStep;
	}

	@ManyToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "transaction_submit_id", nullable = false)
	public TransactionSubmit getTransactionSubmit() {
		return this.transactionSubmit;
	}

	public void setTransactionSubmit(TransactionSubmit transactionSubmit) {
		this.transactionSubmit = transactionSubmit;
	}

	@Column(name = "sequence_name", nullable = false, length = 8)
	public String getSequenceName() {
		return this.sequenceName;
	}

	public void setSequenceName(String sequenceName) {
		this.sequenceName = sequenceName;
	}

	@Column(name = "iterations", nullable = false)
	public byte getIterations() {
		return this.iterations;
	}

	public void setIterations(byte iterations) {
		this.iterations = iterations;
	}

	@Column(name = "rollback_iterations", nullable = false)
	public byte getRollbackIterations() {
		return this.rollbackIterations;
	}

	public void setRollbackIterations(byte rollbackIterations) {
		this.rollbackIterations = rollbackIterations;
	}

	@Column(name = "input", nullable = false)
	public byte[] getInput() {
		return this.input;
	}

	public void setInput(byte[] input) {
		this.input = input;
	}

	@Column(name = "output", nullable = false)
	public byte[] getOutput() {
		return this.output;
	}

	public void setOutput(byte[] output) {
		this.output = output;
	}

	@Column(name = "rollback_output", nullable = false)
	public byte[] getRollbackOutput() {
		return this.rollbackOutput;
	}

	public void setRollbackOutput(byte[] rollbackOutput) {
		this.rollbackOutput = rollbackOutput;
	}

	@Column(name = "error", nullable = false)
	public byte[] getError() {
		return this.error;
	}

	public void setError(byte[] error) {
		this.error = error;
	}

	@Column(name = "rollback_error", nullable = false)
	public byte[] getRollbackError() {
		return this.rollbackError;
	}

	public void setRollbackError(byte[] rollbackError) {
		this.rollbackError = rollbackError;
	}

	@Column(name = "status", nullable = false, length = 16)
	public String getStatus() {
		return this.status;
	}

	public void setStatus(String status) {
		this.status = status;
	}

	@Column(name = "execution_time", nullable = false)
	public int getExecutionTime() {
		return this.executionTime;
	}

	public void setExecutionTime(int executionTime) {
		this.executionTime = executionTime;
	}

	@Temporal(TemporalType.TIMESTAMP)
	@Column(name = "created", nullable = false, length = 0)
	public Date getCreated() {
		return this.created;
	}

	public void setCreated(Date created) {
		this.created = created;
	}

	@Temporal(TemporalType.TIMESTAMP)
	@Column(name = "updated", nullable = false, length = 0)
	public Date getUpdated() {
		return this.updated;
	}

	public void setUpdated(Date updated) {
		this.updated = updated;
	}

}