.class public Lcom/moyoung/ring/user/findring/FindRingViewModel;
.super Landroidx/lifecycle/AndroidViewModel;
.source "SourceFile"


# instance fields
.field private final a:Lcom/moyoung/ring/common/event/EventLiveData;

.field private final b:Lcom/moyoung/ring/common/event/EventLiveData;


# direct methods
.method public constructor <init>(Landroid/app/Application;)V
    .locals 0

    .line 1
    invoke-direct {p0, p1}, Landroidx/lifecycle/AndroidViewModel;-><init>(Landroid/app/Application;)V

    .line 2
    .line 3
    .line 4
    new-instance p1, Lcom/moyoung/ring/common/event/EventLiveData;

    .line 5
    .line 6
    invoke-direct {p1}, Lcom/moyoung/ring/common/event/EventLiveData;-><init>()V

    .line 7
    .line 8
    .line 9
    iput-object p1, p0, Lcom/moyoung/ring/user/findring/FindRingViewModel;->a:Lcom/moyoung/ring/common/event/EventLiveData;

    .line 10
    .line 11
    new-instance p1, Lcom/moyoung/ring/common/event/EventLiveData;

    .line 12
    .line 13
    invoke-direct {p1}, Lcom/moyoung/ring/common/event/EventLiveData;-><init>()V

    .line 14
    .line 15
    .line 16
    iput-object p1, p0, Lcom/moyoung/ring/user/findring/FindRingViewModel;->b:Lcom/moyoung/ring/common/event/EventLiveData;

    .line 17
    .line 18
    return-void
.end method


# virtual methods
.method public a()Lcom/moyoung/ring/common/event/EventLiveData;
    .locals 1

    .line 1
    iget-object v0, p0, Lcom/moyoung/ring/user/findring/FindRingViewModel;->a:Lcom/moyoung/ring/common/event/EventLiveData;

    .line 2
    .line 3
    return-object v0
.end method

.method public b(I)V
    .locals 1

    .line 1
    iget-object v0, p0, Lcom/moyoung/ring/user/findring/FindRingViewModel;->a:Lcom/moyoung/ring/common/event/EventLiveData;

    .line 2
    .line 3
    invoke-static {p1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    .line 4
    .line 5
    .line 6
    move-result-object p1

    .line 7
    invoke-virtual {v0, p1}, Lcom/kunminx/architecture/ui/callback/UnPeekLiveData;->setValue(Ljava/lang/Object;)V

    .line 8
    .line 9
    .line 10
    return-void
.end method

.method public c()V
    .locals 2

    .line 1
    # Call t3.l.r().w() to check connection status
    invoke-static {}, Lt3/l;->r()Lt3/l;

    move-result-object v0

    invoke-virtual {v0}, Lt3/l;->w()Z

    move-result v0

    if-nez v0, :cond_connected

    # If not connected, set state to 2 (Unconnected) and return
    const/4 v0, 0x2

    invoke-virtual {p0, v0}, Lcom/moyoung/ring/user/findring/FindRingViewModel;->b(I)V

    return-void

    :cond_connected
    iget-object v0, p0, Lcom/moyoung/ring/user/findring/FindRingViewModel;->a:Lcom/moyoung/ring/common/event/EventLiveData;

    .line 2
    .line 3
    const/4 v1, 0x1

    .line 4
    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    .line 5
    .line 6
    .line 7
    move-result-object v1

    .line 8
    invoke-virtual {v0, v1}, Lcom/kunminx/architecture/ui/callback/UnPeekLiveData;->setValue(Ljava/lang/Object;)V

    .line 9
    .line 10
    .line 11
    invoke-static {}, Lz3/b3;->Y()Lz3/b3;

    .line 12
    .line 13
    .line 14
    move-result-object v0

    .line 15
    invoke-virtual {v0}, Lz3/b3;->L1()V

    .line 16
    .line 17
    .line 18
    return-void
.end method

.method public d()V
    .locals 2

    .line 1
    iget-object v0, p0, Lcom/moyoung/ring/user/findring/FindRingViewModel;->a:Lcom/moyoung/ring/common/event/EventLiveData;

    .line 2
    .line 3
    const/4 v1, 0x0

    .line 4
    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    .line 5
    .line 6
    .line 7
    move-result-object v1

    .line 8
    invoke-virtual {v0, v1}, Lcom/kunminx/architecture/ui/callback/UnPeekLiveData;->setValue(Ljava/lang/Object;)V

    .line 9
    .line 10
    .line 11
    invoke-static {}, Lz3/b3;->Y()Lz3/b3;

    .line 12
    .line 13
    .line 14
    move-result-object v0

    .line 15
    invoke-virtual {v0}, Lz3/b3;->N1()V

    .line 16
    .line 17
    .line 18
    return-void
.end method
