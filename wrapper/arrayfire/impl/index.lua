--- Core index module.

-- Modules --
local af = require("arrayfire_lib")

-- Forward declarations --

-- Exports --
local M = {}

-- See also: https://github.com/arrayfire/arrayfire/blob/devel/src/api/cpp/index.cpp

--
function M.Add (array_module)
	-- Import these here since the array module is not yet registered.
--[[
///
/// \brief Wrapper for af_index.
///
/// This class is a wrapper for the af_index struct in the C interface. It
/// allows implicit type conversion from valid indexing types like int,
/// \ref af::seq, \ref af_seq, and \ref af::array.
///
/// \note This is a helper class and does not necessarily need to be created
/// explicitly. It is used in the operator() overloads to simplify the API.
///
class AFAPI index {

    af_index_t impl;
    public:
    ///
    /// \brief Default constructor. Equivalent to \ref af::span
    ///
    index();
    ~index();

    ///
    /// \brief Implicit int converter
    ///
    /// Indexes the af::array at index \p idx
    ///
    /// \param[in] idx is the id of the index
    ///
    /// \sa indexing
    ///
    index(const int idx);

    ///
    /// \brief Implicit seq converter
    ///
    /// Indexes the af::array using an \ref af::seq object
    ///
    /// \param[in] s0 is the set of indices to parse
    ///
    /// \sa indexing
    ///
    index(const af::seq& s0);

    ///
    /// \brief Implicit seq converter
    ///
    /// Indexes the af::array using an \ref af_seq object
    ///
    /// \param[in] s0 is the set of indices to parse
    ///
    /// \sa indexing
    ///
    index(const af_seq& s0);

    ///
    /// \brief Implicit int converter
    ///
    /// Indexes the af::array using an \ref af::array object
    ///
    /// \param[in] idx0 is the set of indices to parse
    ///
    /// \sa indexing
    ///
    index(const af::array& idx0);

#if AF_API_VERSION >= 31
    ///
    /// \brief Copy constructor
    ///
    /// \param[in] idx0 is index to copy.
    ///
    /// \sa indexing
    ///
    index(const index& idx0);
#endif

    ///
    /// \brief Returns true if the \ref af::index represents a af::span object
    ///
    /// \returns true if the af::index is an af::span
    ///
    bool isspan() const;

    ///
    /// \brief Gets the underlying af_index_t object
    ///
    /// \returns the af_index_t represented by this object
    ///
    const af_index_t& get() const;
]]

--[[
array lookup(const array &in, const array &idx, const int dim)
{
    af_array out = 0;
    AF_THROW(af_lookup(&out, in.get(), idx.get(), getFNSD(dim, in.dims())));
    return array(out);
}

void copy(array &dst, const array &src,
          const index &idx0,
          const index &idx1,
          const index &idx2,
          const index &idx3)
{
    unsigned nd = dst.numdims();

    af_index_t indices[] = {idx0.get(),
                            idx1.get(),
                            idx2.get(),
                            idx3.get()};

    af_array lhs = dst.get();
    const af_array rhs = src.get();
    AF_THROW(af_assign_gen(&lhs, lhs, nd, indices, rhs));
}

index::index() {
    impl.idx.seq = af_span;
    impl.isSeq = true;
    impl.isBatch = false;
}

index::index(const int idx) {
    impl.idx.seq = af_make_seq(idx, idx, 1);
    impl.isSeq = true;
    impl.isBatch = false;
}

index::index(const af::seq& s0) {
    impl.idx.seq = s0.s;
    impl.isSeq = true;
    impl.isBatch = s0.m_gfor;
}

index::index(const af_seq& s0) {
    impl.idx.seq = s0;
    impl.isSeq = true;
    impl.isBatch = false;
}

index::index(const af::array& idx0) {
    array idx = idx0.isbool() ? where(idx0) : idx0;
    af_array arr = 0;
    AF_THROW(af_retain_array(&arr, idx.get()));
    impl.idx.arr = arr;

    impl.isSeq = false;
    impl.isBatch = false;
}

index::index(const af::index& idx0) {
    *this = idx0;
}

index::~index() {
    if (!impl.isSeq)
        af_release_array(impl.idx.arr);
}

index & index::operator=(const index& idx0) {
    impl = idx0.get();
    if(impl.isSeq == false){
        // increment reference count to avoid double free
        // when/if idx0 is destroyed
        AF_THROW(af_retain_array(&impl.idx.arr, impl.idx.arr));
    }
    return *this;
}

#if __cplusplus > 199711L
index::index(index &&idx0) {
    impl = idx0.impl;
}

index& index::operator=(index &&idx0) {
    impl = idx0.impl;
    return *this;
}
#endif


static bool operator==(const af_seq& lhs, const af_seq& rhs) {
    return lhs.begin == rhs.begin && lhs.end == rhs.end && lhs.step == rhs.step;
}

bool index::isspan() const
{
    return impl.isSeq == true && impl.idx.seq == af_span;
}

const af_index_t& index::get() const
{
    return impl;
}
]]

end

-- TODO: Add "index" environment type?

-- Export the module.
return M