package com.fonality.dao;

import java.io.Serializable;
import java.util.Collection;
import java.util.List;

import javax.persistence.NoResultException;

import org.apache.log4j.Logger;
import org.hibernate.HibernateException;
import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.springframework.beans.factory.annotation.Autowired;

import com.fonality.util.ObjectUtils;

/**
 * The abstractDAO is the super class for all DAO objects in the system. It
 * provides the basic facilities for persisting the defined type. It also
 * provides a collection of helper methods to make writing queries and working
 * with the entity manager easier.
 * 
 * @author matt_filion
 * 
 */
public abstract class AbstractDAO<T> {

	private static Logger logger = Logger
			.getLogger(AbstractDAO.class.getName());

	protected abstract Class<T> getType();

	@Autowired
	public SessionFactory sessionFactory;
	

	/**
	 * Loads the object for the given generic DAO type class and provided id.
	 * 
	 * @param id
	 * @return
	 */
	public T load(Serializable id) {
		T retVal = null;
		if (id == null) {
			return null;
		}

		try {
			retVal = (T) this.sessionFactory.getCurrentSession().get(getType(),
					id);

		} catch (HibernateException e) {
			logger.error("Error occurred on loading object ", e);
		}

		return retVal;
	}

	/**
	 * Method to load list of objects
	 * 
	 * @param ids
	 * @return Collection
	 * @throws ClassNotFoundException
	 */
	public Collection<T> loadBulk(Collection<? extends Serializable> ids) {

		if (!ObjectUtils.isValid(ids)) {
			return null;
		}

		Query bulkLoad = this.sessionFactory.getCurrentSession().createQuery(
				"FROM " + getType().getName()
						+ " entity WHERE entity.id in (:ids)");

		bulkLoad.setParameter("ids", ids);
		bulkLoad.setCacheable(true);

		return bulkLoad.list();
	}

	/**
	 * Creates or updates the vendor persisted vendor record.
	 * 
	 * @param vendor
	 * @return T Returns the object to the front end in case it's a newly
	 *         created object and redirects the user to to page to edit the
	 *         object in pangea.
	 */
	protected T save(T object) {

		if (logger.isTraceEnabled()) {
			logger.trace("Merge : " + object);
		}

		try {
			this.sessionFactory.getCurrentSession().saveOrUpdate(object);
		} catch (HibernateException e) {
			logger.error("Error occurred on saving object ", e);
		}

		return object;

	}

	/**
	 * Removes a vendor from the systems persistence.
	 * 
	 * @param provider
	 */
	protected void delete(Object object) {
		if (logger.isTraceEnabled()) {
			logger.trace("Remove : " + object);
		}

		try {
			Session session = this.sessionFactory.getCurrentSession();
			session.delete(object);

		} catch (HibernateException e) {
			logger.error("Error occurred on deleting object ", e);
		}
	}

	/**
	 * This will return null if a NoResultsFound exception is thrown when
	 * returning executing "getResultList" against the query. This is handy in a
	 * lot of situations where you simply want to return null instead of using
	 * an exception to say "nothing was found".
	 * 
	 * So this method will return null saying there was no one with a
	 * delinquency found rather than throwing an exception.
	 * 
	 * @return
	 */
	@SuppressWarnings("unchecked")
	protected List<T> handleNoResults(Query query) {
		try {
			return query.list();
		} catch (NoResultException nrE) {
			logger.error("There were no results found for the query '" + query
					+ "'.", nrE);
			return null;
		}

	}

	public SessionFactory getSessionFactory() {
		return sessionFactory;
	}

	public void setSessionFactory(SessionFactory sessionFactory) {
		this.sessionFactory = sessionFactory;
	}

}
