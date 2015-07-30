#ifndef GRAPHBLOCKS_H
#define GRAPHBLOCKS_H

#include <QString>
#include <QQmlEngine>

#define GRAPHBLOCKS_API 

struct GraphblocksContext;

GraphblocksContext* GRAPHBLOCKS_API initializeGraphBlocks();
void GRAPHBLOCKS_API shutdownGraphBlocks( GraphblocksContext* ctx);
void GRAPHBLOCKS_API addGraphBlocksLibrary(QQmlEngine* ctx, const QString& libname, const QString& folder);

#endif // GRAPHBLOCKS_H
