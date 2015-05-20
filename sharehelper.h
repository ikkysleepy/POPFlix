#ifndef SHAREHELPER_H
#define SHAREHELPER_H



#include <QObject>

class ShareHelper : public QObject
{
    Q_OBJECT
public:
    explicit ShareHelper(QObject *parent = 0);
    
signals:
    
public slots:
    //! Shares content with the share-ui interface
    //! \param title The title of the content to be shared
    //! \param url The URL of the content to be shared
    void share(QString title, QString url, QString desc);

};

#endif // SHAREHELPER_H
