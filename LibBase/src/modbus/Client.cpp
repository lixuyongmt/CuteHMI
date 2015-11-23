#include "Client.hpp"
#include "AbstractConnection.hpp"
#include "Exception.hpp"

namespace modbus {

Client::Client(std::unique_ptr<AbstractConnection> connection, QObject * parent):
	QObject(parent),
	m_ir(this, & m_irData, Client::Count<InputRegister>, Client::At<InputRegister>),
	m_r(this, & m_rData, Client::Count<HoldingRegister>, Client::At<HoldingRegister>),
	m_connection(std::move(connection))
{
}

Client::~Client()
{
	for (IrDataContainer::iterator it = m_irData.begin(); it != m_irData.end(); ++it)
		delete it.value();
	m_irData.clear();
	for (RDataContainer::iterator it = m_rData.begin(); it != m_rData.end(); ++it)
		delete it.value();
	m_rData.clear();
}

const QQmlListProperty<InputRegister> & Client::ir() const
{
	return m_ir;
}

const QQmlListProperty<HoldingRegister> & Client::r() const
{
	return m_r;
}

void Client::connect()
{
	try {
		m_connection->connect();
	} catch (Exception & e) {
		emit error(QString::fromLocal8Bit(e.what()), QString::fromLocal8Bit(e.details()));
		return;
	}
	emit connected();
}

void Client::disconnect()
{
	m_connection->disconnect();
	emit disconnected();
}

}
