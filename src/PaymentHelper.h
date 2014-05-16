#ifndef PAYMENTHELPER_H_
#define PAYMENTHELPER_H_

#include <QObject>

namespace bb {
    namespace platform {
        class ExistingPurchasesReply;
        class PaymentManager;
        class PurchaseReply;
    }
}

namespace canadainc {
    class Persistance;
}

namespace canadainc {

using namespace bb::platform;

class PaymentHelper : public QObject
{
    Q_OBJECT

    Persistance* m_persistance;
    PaymentManager* m_payment;
    PaymentManager* getPaymentManager();

private slots:
    void existingPurchasesFinished(bb::platform::ExistingPurchasesReply* reply);
    void purchaseFinished(bb::platform::PurchaseReply* reply);

signals:
    void initialize();

public:
    PaymentHelper(Persistance* persist, QObject* parent=NULL);
    virtual ~PaymentHelper();

    Q_SLOT void refreshPurchases();
    Q_SLOT void requestPurchase(QString const& sku, QString const& name);
};

} /* namespace canadainc */

#endif /* PAYMENTHELPER_H_ */
