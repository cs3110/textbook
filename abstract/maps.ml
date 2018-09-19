module type MyMap = sig

  (** [('k,'v) t] is the type of a map containing bindings 
      from keys of type ['k] to values of type ['v]. *)
  type ('k,'v) t
  
  (** [empty] is the map containing no bindings. *)
  val empty : ('k,'v) t
  
  (** [mem k m] is true if [k] is bound in [m] and false otherwise. *)
  val mem : 'k -> ('k,'v) t -> bool
  
  (** [find k m] is [v] iff [k] is bound to [v] in [m]. 
      Raises: [Not_found] if [k] is not bound in [m]. *)
  val find : 'k -> ('k,'v) t -> 'v
  
  (** [add k v m] is the map [m'] that contains the same bindings
      as [m], and additionally binds [k] to [v]. If [k] was
      already bound in [m], its old binding is replaced by
      the new binding in [m']. *)
  val add : 'k -> 'v -> ('k,'v) t -> ('k,'v) t
  
  (** [remove k m] is the map [m'] that contains the same bindings
      as [m], except that [k] is unbound in [m']. *)
  val remove : 'k -> ('k,'v) t -> ('k,'v) t

end 
